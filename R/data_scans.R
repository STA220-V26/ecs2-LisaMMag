# Data scans -------------------------------------------------------------

# Add table scans
# Slow! Follow: https://github.com/rstudio/pointblank/issues/550

# For one data set at the time
export_data_scan <- function(dt, name, max_rows = 1e3) { #defines the funtion and takes the dataframe with max 1,000 rows
  data <- if (!is.null(max_rows) && nrow(dt) > max_rows) { #checks if the dataframe is greater than the row limit
    warning("Only useing a sample of the data!") #incase it is too large, print this message to warn that it is a sample, not the whole
    dt[sample.int(nrow(dt), max_rows)] #randomly selects 1000 rows
  } else {
    copy(dt) #if the data is less than 1000 rows, it copies the whole thing
  }
  # Does not work with the IDate format it seems
  data[, names(.SD) := lapply(.SD, as.Date), .SDcols = is.Date] #ensures all dates are in standard format

  # Create folder if it does not already exist
  if (!fs::dir_exists("data_scans")) { #checks if data_scans exists
    fs::dir_create("data_scans")  #if not it creates it
  }
  outname <- paste0("data_scans/", name, ".html") #defines a file path
  scan_data(data, sections = "OMSV") |> # don't work with all default sections: this runs the pointblank scan, limited by OMSV
    export_report(outname) #saves the scan as an html file
  outname # return file name
}

# for a list of multiple data sets
export_data_scans <- function(dts_fixed) { #takes the dataframe containing multiple dataframes
  with(dts_fixed, setNames(data, name)) |> #turns it into a list
    iwalk(export_data_scan, .progress = TRUE) #loops through list, sends data to the first function. progress=TRUE gives the loading bar
  "data_scans" # return folder name
}
