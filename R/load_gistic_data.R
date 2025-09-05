suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(janitor)
})

source(file.path(get_script_dir(), "R/load_genome_info.R"))

#' Load and process GISTIC data
#' 
#' Reads GISTIC amplification/deletion results and converts genomic coordinates
#' to genome-wide positions for plotting. Returns separate data frames for
#' amplifications and deletions.
#' 
#' @param gfile Path to GISTIC results file (TSV format)
#' @return List with Amp and Del data frames containing genomic positions and q-values
load_gistic_data <- function(gfile) {
  hg19 <- load_genome_info()
  
  processed_data <- read_tsv(gfile, show_col_types = FALSE, progress = FALSE) |>
    clean_names() |>
    mutate(chromosome = as.character(chromosome)) |>
    left_join(hg19, by = "chromosome") |>
    mutate(gPos = start + g_offset) |>
    select(type, chromosome, gPos, log10_q_value)
  
  split(processed_data, processed_data$type)
}

