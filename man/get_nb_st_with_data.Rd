% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/helper.R
\name{get_nb_st_with_data}
\alias{get_nb_st_with_data}
\title{Getting number of stations with data for selected parameter}
\usage{
get_nb_st_with_data(meteo_lst, par)
}
\arguments{
\item{meteo_lst}{nested list of lists with dataframes.
Nested structure meteo_lst -> data -> Station ID -> Parameter -> Dataframe (DATE, PARAMETER).}

\item{par}{is weather variable to extract (i.e. "PCP", "SLR", etc)}
}
\value{
number of stations with data for this parameter.
}
\description{
Getting number of stations with data for selected parameter
}
\examples{
\dontrun{
get_nb_st_with_data(meteo_lst, "PCP")
}
}
\keyword{internal}
