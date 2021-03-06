% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_ag_bulletin.R
\name{get_ag_bulletin}
\alias{get_ag_bulletin}
\title{BoM agriculture bulletin information}
\usage{
get_ag_bulletin(state = NULL)
}
\arguments{
\item{state}{Australian state or territory as postal code, see details for
instruction.}
}
\value{
Data frame of a Australia BoM agricultural bulletin information.  For more
details see the vignette "Ag Bulletin Fields":
\code{vignette("Ag Bulletin Fields", package = "bomrang")} for a complete
list of fields and units.
}
\description{
Fetch the BoM agricultural bulletin information and return a tidy data frame
}
\details{
Allowed state and territory postal codes, only one state per request
or all using \code{AUS}.
 \describe{
   \item{NSW}{New South Wales}
   \item{NT}{Northern Territory}
   \item{QLD}{Queensland}
   \item{SA}{South Australia}
   \item{TAS}{Tasmania}
   \item{VIC}{Victoria}
   \item{WA}{Western Australia}
   \item{AUS}{Australia, returns bulletin for all states}
 }
}
\examples{
\dontrun{
ag_bulletin <- get_ag_bulletin(state = "QLD")
}
}
\references{
Australian Bureau of Meteorology (BoM) Weather Data Services Agriculture Bulletins
\url{http://www.bom.gov.au/catalogue/observations/about-agricultural.shtml}

Australian Bureau of Meteorology (BoM) Weather Data Services Observation of Rainfall
\url{http://www.bom.gov.au/climate/how/observations/rain-measure.shtml}
}
\author{
Adam H Sparks, \email{adamhsparks@gmail.com}
}
