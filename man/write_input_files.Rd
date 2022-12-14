% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/writing.R
\name{write_input_files}
\alias{write_input_files}
\title{Writing input files (all except TMP)}
\usage{
write_input_files(write_path, sp_df, meteo_lst, par)
}
\arguments{
\item{write_path}{path to folder where results should be written.}

\item{sp_df}{SpatialPointsDataFrame with resulting interpolated data.}

\item{meteo_lst}{nested list of lists with dataframes.}

\item{par}{weather variable (i.e. "PCP", "SLR", etc).}
}
\value{
weather data text files for virtual stations (created during interpolation)
in format usable by the SWAT model.
}
\description{
Writing input files (all except TMP)
}
\examples{
\dontrun{
write_input_files("./output/", sp_df, "PCP")
}
}
