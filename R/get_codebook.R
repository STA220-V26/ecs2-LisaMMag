get_codebook <- function() { #define a new function
  tabs <-
    "https://github.com/synthetichealth/synthea/wiki/CSV-File-Data-Dictionary" |> #link to data
    rvest::read_html() |> #download/read the html code of the webpage contents
    rvest::html_elements("table") |> #finds tables in the code
    rvest::html_table() #makes them into data frames
  #now we have tabs, a list of tables 

  tab_desc <- tabs[[1]] #the first table describes the other tables, so this is saved
  tab_vars <- setNames(tabs[-1], tab_desc$File) #then the first table is used to name the other tables (not the first one)

  cb <- #make one big table
    suppressMessages( #supresses messages that could clutter up the console
      dplyr::bind_rows(tab_vars, .id = "file") |> #bind all the tables together into one table
        janitor::clean_names() |> #makes all the column names the same
        dplyr::rename_with(tolower) |> #line I added to make all column names lowercase
        dplyr::rename(key = x1) |> #renames a column to x1
        dplyr::mutate(dplyr::across(dplyr::where(is.character), \(x) {
          dplyr::na_if(x, "") #makes sure blanks are actually NA's
        })) |>
        dplyr::mutate(
          required = as.logical(required), #makes the column "required" into a boolian
          key = factor(key, c("🔑", "🗝️"), c("primary", "foreign")) #relabels emogies with words
        ) |>
        data.table::setDT() #makes the final product into a datatable
    )
  cb #return the codeblock 
}
