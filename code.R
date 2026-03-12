tar_make()
tar_visnetwork()

tar_load(dt_patients)

dim(dt_patients) #6851 (rows)   28 (columns)
head(dt_patients) #lots of personal data
dplyr::glimpse(dt_patients)
View(dt_patients) #opens it up in 
summary(dt_patients) #gives averages and stuff (info on each column)
skimr::skim(dt_patients)
#Column type frequency:                
#  character                18         
#  Date                     2          
#  numeric                  8       
#There's no missing for any of the characters. There's 6000 missing deathdates (maybe only 851 have died so far?), and for numeric
#only missing for fips (714)

tar_source()
#this loads all the functions into the functions in the side
get_codebook()
#Get an output where you see the file it came from, and all the stuff within that file




tar_load(codebook)
cb_patients <- codebook[file == "patients.csv"]

# Which columns are relevant for `patients`?
cb_patients[, column_name]

# Well, those columns don't actually match the column names used in the data!
# Do they?
names(dt_patients)
# Do you notice a pattern in how the names differ?
# Let's fix that
cb_patients[, column_name := tolower(column_name)]

# Do we have any variables which are not documented?
setdiff(names(dt_patients), cb_patients[, column_name]) # Non-documented

# Yep, so let's fix that manually for now
cb_patients[, column_name := gsub(" county code", "", column_name)]






library(tidyverse)
library(data.table)

names_in_data <-
  tibble(files = dir("_targets/objects", "dt_")) |>
  mutate(
    column_name = map(files, \(x) names(tar_read_raw(x)), .progress = TRUE),
    file = paste0(gsub("dt_", "", files), ".csv")
  ) |>
  unnest(column_name) |>
  setDT()

codebook[, column_name := tolower(column_name)]

names_in_data[!codebook, on = c("file", "column_name")]
codebook[!names_in_data, on = c("file", "column_name")] |> View()
#essentially comparing the map (the codebook) against the territory 
#(the actual data files currently sitting in your targets cache)


library(labelled)
#add labels to patient data
labelled::var_label(dt_patients) <-
  cb_patients[, setNames(description, column_name)]

labelled::look_for(dt_patients, "ssn")
#ssn = Patient Social Security identifier

labelled::look_for(dt_patients, "income")
#income = Annual income for the Patient int

dt_patients[, hist(income)]


gtsummary::tbl_summary(dt_patients[, .(
  marital,
  race,
  ethnicity,
  gender,
  state
)])
#we only have a sample of under 7 thousand, and only from 6 states. 
#it seems to be somewhat representative (half male, half female, mostly white),
#but the marital status has a lot of missing, which makes this less generalizable.


library(pointblank)

dt_patients |> pointblank::scan_data(sections = "OMSV")
