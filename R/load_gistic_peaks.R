# Load GISTIC peak data from lesions file
# Extracts copy number alteration peaks with coordinates and q-values


#' Parse peak coordinate strings into separate columns
#'
#' @param ss Character vector of genomic coordinate strings in format "chr1:123-456"
#' @return Tibble with columns: chrom, start, end
parse_peak_strings <- function(ss) {
  str_extract(ss, "chr([^:]+):(\\d+)-(\\d+)", group = c(1, 2, 3)) |>
    as_tibble(.name_repair = "minimal") |>
    rename(chrom = 1, start = 2, end = 3)
}

#' Load GISTIC peak data from lesions file
#'
#' Reads GISTIC lesions file, filters for copy number alterations,
#' and extracts peak coordinates and q-values.
#'
#' @param lesions_file Path to GISTIC lesions file
#' @return Tibble with columns: type, descriptor, q_values, chrom, start, end, pos, unique_name
load_gistic_peaks <- function(lesions_file) {
  read_tsv(lesions_file,
           show_col_types = FALSE,
           col_types = cols(.default = "c")) |>
    janitor::clean_names() |>
    rename_at(vars(matches("^residual_")), ~ "residual_q_values") |>
    select(unique_name:residual_q_values,
           -wide_peak_limits,
           -region_limits) |>
    filter(grepl(" - CN", unique_name)) |>
    mutate(type = gsub(" .*", "", unique_name)) |>
    mutate(coor = parse_peak_strings(peak_limits)) |>
    unnest(coor) |>
    type_convert() |>
    mutate(pos=floor((start+end)/2)) |>
    select(type, descriptor, q_values:end,pos,unique_name)
}

# like if __name__=="__main__"
if (!interactive() && sys.nframe() == 0) {
  suppressPackageStartupMessages({
    library(tidyverse)
    library(readr)
  })
  lesions_file <- "all_lesions.conf_99.txt"
  peakTbl <- load_gistic_peaks(lesions_file)
  print(str(peakTbl))
}