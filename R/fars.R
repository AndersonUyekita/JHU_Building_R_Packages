############################################################
#                                                          #
#  Author : Anderson Hitoshi Uyekita                       #
#  Project: Building R Packages - Week 2                   #
#                                                          #
############################################################

#' Week 2 - Assignment
#'
#' This functions will read just only one archive. The input of this function is the filename to be
#' imported. These archive has data of the US National Highway Traffic Safety Administration's, and
#' this is a csv file. Keep in mind that the filename will be generate by the make_filename function.
#'
#' @param filename Is a character string which represents the archive's name.
#'
#' @return This functions returns a data frame of the imported data in case of an invalid name it will return
#'         a message error "file XXXX does not exist".
#'
#' @importFrom dplyr tbl_df
#'
#' @importFrom readr read_csv
#'
#' @keywords coursera
#'
#' @examples
#' \dontrun{fars_read(filename = "accident_2013.csv.bz2")}
#'
#' @export
fars_read <- function(filename) {
        if(!file.exists(filename))
                stop("file '", filename, "' does not exist")
        data <- suppressMessages({
                readr::read_csv(filename, progress = FALSE)
        })
        dplyr::tbl_df(data)
}

#' This functions will generate the filename string which will be used in the fars_read function
#'
#' @param year Could be one number or a list of numbers.
#'
#' @return The return of this function could be a single string or a list, depends of its inputs.
#'
#' @examples
#' \dontrun{make_filename(year = 2015)}
#' \dontrun{make_filename(year = c(2013,2014))}
#'
#' @export
make_filename <- function(year) {
        year <- as.integer(year)
        sprintf("accident_%d.csv.bz2", year)
}

#' This functions will import several years by the using of the fars_read function many times. There are some
#' data manipulation as a creation of a column called year (using mutate) and a selection of two variable per year.
#'
#' @param years Could be a single year or a list of years.
#'
#' @return The results of this function will be a list with only the columns MONTH and year, as you can
#'         confirm watching the select(MONTH, year). If any year in the list was invalid the function show
#'         a warning message.
#'
#' @importFrom magrittr %>%
#'
#' @importFrom dplyr mutate select
#'
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{fars_read_years(years = list(2013,2014,2015))}
#'
#' @export
fars_read_years <- function(years) {
        lapply(years, function(year) {
                file <- make_filename(year)
                tryCatch({
                        dat <- fars_read(file)
                        dplyr::mutate(dat, year = year) %>%
                                dplyr::select(.data$MONTH, .data$year)
                }, error = function(e) {
                        warning("invalid year: ", year)
                        return(NULL)
                })
        })
}

#' This function perform the summarization which consist in the lines number of each dataset, and
#' bind the separated dataset into one data.frame (using bind_rows). Later transform rows into column
#' by the spread function. As a result, years in columns rows as months.
#'
#' @param years Could be a single year or a list pf years.
#'
#' @return The return will be a data.frame with years in columns and months in rows. Each row represent
#'         the number of accidents.
#'
#' @importFrom tidyr spread
#'
#' @importFrom dplyr bind_rows group_by summarize n
#'
#' @importFrom magrittr %>%
#'
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{fars_summarize_years(years = list(2013,2014,2015))}
#'
#' @export
fars_summarize_years <- function(years) {
        dat_list <- fars_read_years(years)
        dplyr::bind_rows(dat_list) %>%
                dplyr::group_by(.data$year, .data$MONTH) %>%
                dplyr::summarize(n = dplyr::n()) %>%
                tidyr::spread(.data$year,.data$n)
}

#' This function perform the data visualization, for each set of state and years will be displayed the state and
#' points, where points represents the accidents in this state during the given years.
#'
#' @param year Could be a single year or a list of years.
#'
#' @param state.num The operator must know the code of the state to generate the desired map.
#'
#' @return The return will be a map with point ploted representing accidents. If the state code is not correct
#'         an error will be shown saying "invalid STATE number".
#'
#' @importFrom graphics points
#'
#' @importFrom maps map
#'
#' @importFrom dplyr filter
#'
#' @examples
#' \dontrun{fars_map_state(state.num = 1, year = 2013)}
#' \dontrun{fars_map_state(state.num = 56, year = 2015)}
#'
#' @export
fars_map_state <- function(state.num, year) {
        filename <- make_filename(year)
        data <- fars_read(filename)
        state.num <- as.integer(state.num)

        if(!(state.num %in% unique(data$STATE)))
                stop("invalid STATE number: ", state.num)
        data.sub <- dplyr::filter(data, .data$STATE == state.num)
        if(nrow(data.sub) == 0L) {
                message("no accidents to plot")
                return(invisible(NULL))
        }
        is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
        is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
        with(data.sub, {
                maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
                          xlim = range(LONGITUD, na.rm = TRUE))
                graphics::points(LONGITUD, LATITUDE, pch = 46)
        })
}
