
#' Update internal database with latest BoM forecast locations
#'
#' @description
#' Download the latest forecast locations from the BoM server and update
#' bomrang's internal database of précis forecast locations,
#' \code{\link{AAC_codes}} used by \code{\link{get_precis_forecast}}.  There is
#' no need to use this unless you know that a forecast location exists in a
#' more current version of the BoM précis forecast location database that is not
#' available in the database distributed with \code{\link{bomrang}}.
#'
#' @examples
#' \dontrun{
#' update_forecast_locations()
#' }
#' @return Updated internal database of BoM précis forecast locations
#'
#' @references
#' Australian Bureau of Meteorology (BoM) Weather Data Services
#' \url{http://www.bom.gov.au/catalogue/data-feeds.shtml}
#'
#'
#' @author Adam H Sparks, \email{adamhsparks@gmail.com}
#' @export
#'
update_forecast_locations <- function() {
  original_timeout <- options("timeout")[[1]]
  options(timeout = 300)
  on.exit(options(timeout = original_timeout))

  # fetch new database from BoM server
  curl::curl_download(
    "ftp://ftp.bom.gov.au/anon/home/adfd/spatial/IDM00013.dbf",
    destfile = paste0(tempdir(), "AAC_codes.dbf"),
    mode = "wb"
  )

  # import BoM dbf file
  AAC_codes <-
    foreign::read.dbf(paste0(tempdir(), "AAC_codes.dbf"), as.is = TRUE)
  AAC_codes <- AAC_codes[, c(2:3, 7:9)]

  # overwrite the existing isd_history.rda file on disk
  message("Overwriting existing database")

  pkg <- system.file(package = "bomrang")
  path <-
    file.path(file.path(pkg, "data"), paste0("AAC_codes.rda"))
  save(AAC_codes, file = path, compress = "bzip2")
}
