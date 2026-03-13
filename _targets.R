#install.packages("targets")
library(targets)
#install.packages("tarchetypes")
library(tarchetypes) # For extra target archetypes
#install.packages("qs2")
library(qs2)
#install.packages("qs") #not available on CRAN, so might need to get it off 
#library(qs)

# Which packages do you need?
pkgs <- c(
  "janitor", # data cleaning
  "labelled", # labeling data
  "pointblank", # data validation and exploration
  "rvest", # get data from web pages
  "tidyverse", # Data management
  "data.table", # fast data management
  "fs", # to work wit hthe file system
  "zip", # manipulate zip files
  "targets",
  "tarchetypes",
  "qs2"
)
# Install packages if you don't already have them
#install.packages(setdiff(pkgs, row.names(installed.packages())))

# NOTE! The packages specified in `pkgs` will be used by the targets.
# They will, however, not be available within the interactive session unless you also load them here:
#invisible(lapply(pkgs, library, character.only = TRUE))

# Set target options:
tar_option_set(
  # Packages that your targets need for their tasks:
  packages = pkgs,
  format = "qs", # Default storage format. qs (which is actually qs2) is fast.
)

# Run the R scripts stored in the R/ folder where your have stored your custom functions:
tar_source()

# We first download the data health care data of interest
if (!fs::file_exists("data.zip")) {
  message("Downloading data.zip from GitHub")
  curl::curl_download(
    "https://github.com/STA220/cs/raw/refs/heads/main/data.zip",
    "data.zip",
    quiet = FALSE
  )
}


# Define targets pipeline ------------------------------------------------

# Help: https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

list(
  #define the zip file path
  tar_target(zipdata, "data.zip", format = "file"),

  #unzip the file
  tar_target(cvs_files, zip::unzip(zipdata)),

  #dynamically read all files found in data-fixed
  #I removed the fs::dir_map line because it was causing the error
  tar_map(
   values = tibble::tibble(path = dir("data-fixed", full.names = TRUE)) |> #looks inside data-fixed and gets the full path for every file inside
     dplyr::mutate(name = tools::file_path_sans_ext(basename(path))), #creates a clean name column by stripping away the folder path and the file extension
   tar_target(dt, fread(path)), #for every row in the table above, tar_map will generate a target named dt
   names = name, #tells tar_map how to name the resulting targets in the pipeline
   descriptions = NULL
  ),
  #Bascially, it is scanning the folder of files and creating a separate "read" step for every single file it finds, all at once.
  
  #the codebook
  tar_target(codebook, get_codebook()),

  tar_target(data_scan_patient, export_data_scan(dt_patients, "patients"), format = "file"),

  tar_target(data_scan_allergies, export_data_scan(dt_allergies, "allergies"), format = "file"),

  tar_target(data_scan_conditions, export_data_scan(dt_conditions, "conditions"), format = "file")
)
