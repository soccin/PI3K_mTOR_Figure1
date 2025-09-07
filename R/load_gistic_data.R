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

  read_tsv(gfile, show_col_types = FALSE, progress = FALSE) |>
    janitor::clean_names() |>
    mutate(chromosome = as.character(chromosome)) |>
    left_join(hg19, by = "chromosome") |>
    mutate(gPos = start + g_offset) |>
    arrange(gPos) |>
    select(type, chromosome, gPos, log10_q_value) %>%
    split(.$type)

}

