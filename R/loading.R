
# Template loading functions --------------------------------------------------------------------

#' Function providing loading for data templates (with single and multiple data sheets)
#' (data should have been cleaned before).
#'
#' @param template_path path to *.xlsx file. 
#' @param epsg_code EPSG code for station coordinates (default 4326 for WGS 84 coordinate system)  system
#' @return list of two: stations dataframe, which contains station information,  
#' second member of list contains contains measurement data in dataframe (if data is in one sheet)
#' or nested list of dataframes with each parameter in separate dataframe. 
#' @importFrom dplyr mutate %>%
#' @importFrom readxl read_xlsx excel_sheets
#' @importFrom tidyr drop_na
#' @export 
#'
#' @examples
#' temp_path <- system.file("extdata", "calibration_data.xlsx", package = "svatools")
#' cal_data <- load_template(temp_path)
#' str(cal_data)

load_template <- function(template_path, epsg_code = 4326){
  print("Loading data from template.")
  ##Loading station location and other info
  st <- load_stations(template_path, epsg_code)
  ##Getting sheet names
  ids <- excel_sheets(template_path) %>% 
    .[!. %in% "Stations"]
  ##Loading data with one data sheet
  if(length(ids) == 1){
    r <- read_xlsx(template_path, ids) %>%
      mutate(DATE = as.POSIXct(DATE, "%Y-%m-%d", tz = "UTC"))
  ##Loading data with many data sheets
  }else if(length(ids) > 1){
    r <- list()
    for (id in ids){
      print(paste("Reading station", id, "data."))
      df <- read_xlsx(template_path, id, guess_max = 10000) 
      for (p in names(df)[-1]){
        r[[id]][[p]] <- df[,c("DATE", p)] %>% 
          drop_na() %>% 
          mutate(DATE = as.POSIXct(DATE, "%Y-%m-%d", tz = "UTC"))
      }
    }
  }else{
    warning("Your template doesn't have data sheets to read.")
    r <- NA
  }
  print("Loading of data is finished.")
  return(list(stations = st, data = r))
}

#' Reading station data from excel templates
#'
#' @param template_path path to *.xlsx file. 
#' @param epsg_code EPSG code for station coordinates system.
#' @return sf dataframe with station information.
#' @importFrom readxl read_xlsx
#' @importFrom sf st_as_sf
#' @importFrom dplyr mutate %>%
#' @importFrom purrr map
#' @export 
#'
#' @examples
#' temp_path <- system.file("extdata", "weather_data.xlsx", package = "svatools")
#' stations <- load_stations(temp_path, 3035)
#' str(stations)
#' library(sf)
#' library(mapview)
#' mapview(st_transform(stations, 4326))

load_stations <- function(template_path, epsg_code){
  read_xlsx(template_path, "Stations") %>% 
    st_as_sf(coords = c("Long", "Lat"), crs = epsg_code) %>% 
    mutate(Long = unlist(map(geometry,1)),
           Lat = unlist(map(geometry,2)))
}

#' Function loading climate data csv files
#'
#' @param f_path character providing path to climate date folder (i.e. "inst/extdata/CORDEX-BC")
#' @param f_lst list providing file name for each weather parameter (default list("PCP" = "prec-1", 
#' "SLR" = "solarRad-1", "RELHUM" = "relHum-1", "TMP_MAX" = "Tmax-1", "TMP_MIN" = "Tmin-1", 
#' "WNDSPD" = "windSpeed-1"))
#' @return nested list of lists with dataframes. 
#' Nested structure meteo_lst -> RCM_MOD-> Parameter -> Dataframe (DATE, PARAMETER).
#' @importFrom dplyr mutate
#' @importFrom utils read.csv
#' @export
#'
#' @examples
#' temp_path <- paste0(system.file("extdata", package = "svatools"), "/CORDEX-BC")
#' cli_lst <- load_climate(temp_path)
#' str(cli_lst)

load_climate <- function(f_path, f_lst = list("PCP" = "prec-1", "SLR" = "solarRad-1", "RELHUM" = "relHum-1", "TMP_MAX" = "Tmax-1", 
                                              "TMP_MIN" = "Tmin-1", "WNDSPD" = "windSpeed-1")){
  r <- list()
  for(c in sub(".*\\/", "", list.dirs(f_path, recursive = FALSE))){
    for (m in sub(".*\\/", "", list.dirs(paste0(f_path, "/", c), recursive = FALSE))){
      for(i in names(f_lst)){
        r[[paste0(c, "_", m)]][[i]] <- read.csv(paste0(f_path, "/", c, "/", m, "/", f_lst[i][[1]], ".csv"), 
                                                header = F, col.names = c("DATE", i)) %>% 
          mutate(DATE = as.POSIXct(DATE, "%Y-%m-%d", tz = "UTC"))
      }
    }
  }
  print("Loading of data is finished.")
  return(r)
}
