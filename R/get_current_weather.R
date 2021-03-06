
#' Current weather observations of a BoM station
#'
#' @param station_name The name of the weather station. Fuzzy string matching
#' via \code{base::agrep} is done.
#' @param latlon A length-2 numeric vector. When given instead of
#' \code{station_name}, the nearest station (in this package) is used, with a
#' message indicating the nearest such station. (See also
#'  \code{\link{sweep_for_stations}}.) Ignored if used in combination with
#' \code{station_name}, with a warning.
#' @param raw Logical. Do not convert the columns \code{data.table} to the
#' appropriate classes. (\code{FALSE} by default.)
#' @param emit_latlon_msg Logical. If \code{TRUE} (the default), and
#' \code{latlon} is selected, a message is emitted before the table is returned
#' indicating which station was actually used (i.e. which station was found to
#' be nearest to the given coordinate).
#' @param as.data.table Return result as a \code{data.table}.
#' @details Note that the column \code{local_date_time_full} is set to a
#' \code{POSIXct} object in the local time of the \strong{user}.
#' For more details see the vignette "Current Weather Fields":
#' \code{vignette("Current Weather Fields", package = "bomrang")}
#' for a complete list of fields and units.
#' @examples
#' \dontrun{
#'   # warning
#'   Melbourne_weather <- get_current_weather("Melbourne")
#'
#'   # no warning
#'   Melbourne_weather <- get_current_weather("Melbourne (Olympic Park)")
#'
#'   # Get weather by latitude and longitude:
#'   get_current_weather(latlon = c(-34, 151))
#' }
#' @author Hugh Parsonage, \email{hugh.parsonage@gmail.com}
#' @importFrom magrittr use_series
#' @importFrom data.table :=
#' @importFrom data.table %chin%
#' @export get_current_weather

get_current_weather <-
  function(station_name,
           latlon = NULL,
           raw = FALSE,
           emit_latlon_msg = TRUE,
           as.data.table = FALSE) {
    if (missing(station_name) && is.null(latlon)) {
      stop("One of 'station_name' or 'latlon' must be provided.")
    }

    if (!missing(station_name)) {
      if (!is.null(latlon)) {
        latlon <- NULL
        warning("Both station_name and latlon provided. Ignoring latlon.")
      }
      stopifnot(is.character(station_name),
                length(station_name) == 1)

      # CRAN NOTE avoidance
      name <- NULL

      station_name <- toupper(station_name)

      # If there's an exact match, use it; else, attempt partial match.
      if (station_name %in% JSONurl_latlon_by_station_name[["name"]]) {
        the_station_name <- station_name
      } else {
        likely_stations <- agrep(pattern = station_name,
                                 x = JSONurl_latlon_by_station_name[["name"]],
                                 value = TRUE)

        if (length(likely_stations) == 0) {
          stop("No station found.")
        }

        the_station_name <- likely_stations[1]
        if (length(likely_stations) > 1) {
          warning(
            "Multiple stations match station_name. Using\n\tstation_name = '",
            the_station_name,
            "'\ndid you mean:\n\tstation_name = '",
            likely_stations[-1],
            "'?"
          )
        }
      }

      json_url <-
        JSONurl_latlon_by_station_name[name == the_station_name][["url"]]

    } else {
      # We have established latlon is not NULL
      if (length(latlon) != 2 || !is.numeric(latlon)) {
        stop("latlon must be a length-2 numeric vector.")
      }

      lat <- latlon[1]
      lon <- latlon[2]

      # CRAN NOTE avoidance: names of JSONurl_latlon_by_station_name
      Lat <- Lon <- NULL

      station_nrst_latlon <-
        JSONurl_latlon_by_station_name %>%
        # Lat Lon are in JSON
        .[which.min(haversine_distance(lat, lon, Lat, Lon))]
      
      if (emit_latlon_msg) {
        on.exit(
          message(
            "Using station_name = '",
            station_nrst_latlon$name,
            "', at latitude = ",
            station_nrst_latlon$Lat,
            ", ",
            "longitude = ",
            station_nrst_latlon$Lon
          )
        )
      }

      json_url <- station_nrst_latlon[["url"]]
    }
    if (isTRUE(httr::http_error(json_url))) {
      stop("A station was matched but a corresponding JSON file was not found at
           bom.gov.au.")
    }

    observations.json <-
      jsonlite::fromJSON(txt = json_url)

    if ("observations" %notin% names(observations.json) ||
        "data" %notin% names(observations.json$observations)) {
      stop("A station was matched but the JSON returned by bom.gov.au was not in
           expected form.")
    }

    # Columns which are meant to be numeric
    double_cols <-
      c("lat",
        "lon",
        "apparent_t",
        "cloud_base_m",
        "cloud_oktas",
        "rain_trace")
    # (i.e. not raw)
    cook <- function(DT, as.DT) {
      if (!data.table::is.data.table(DT)) {
        data.table::setDT(DT)
      }

      DTnoms <- names(DT)

      # CRAN NOTE avoidance
      local_date_time_full <- NULL
      if ("local_date_time_full" %chin% DTnoms) {
        DT[, local_date_time_full := as.POSIXct(
          local_date_time_full,
          origin = "1970-1-1",
          format = "%Y%m%d%H%M%OS",
          tz = ""
        )]
      }

      aifstime_utc <- NULL
      if ("aifstime_utc" %chin% DTnoms) {
        DT[, aifstime_utc := as.POSIXct(aifstime_utc,
                                        origin = "1970-1-1",
                                        format = "%Y%m%d%H%M%OS",
                                        tz = "GMT")]
      }

      for (j in which(DTnoms %chin% double_cols)) {
        data.table::set(DT, j = j, value = force_double(DT[[j]]))
      }

      if (!as.DT) {
        DT <- as.data.frame(DT)
      }

      DT[]
    }

    out <-
      observations.json %>%
      use_series("observations") %>%
      use_series("data")

    if (as.data.table) {
      data.table::setDT(out)
    }

    if (raw) {
      return(out)
    } else {
      return(cook(out, as.DT = as.data.table))
    }
  }
