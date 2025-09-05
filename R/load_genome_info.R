suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
})

#' Load human genome hg19 chromosome information
#' 
#' Reads chromosome sizes from hg19.chrom.sizes file and calculates
#' cumulative genomic offsets for plotting genome-wide coordinates.
#' 
#' @return Data frame with chromosome names, genomic offsets, and lengths
load_genome_info <- function() {
  hg19_chroms <- c(1:22, "X", "Y", "M")
  
  read_tsv(
    "hg19.chrom.sizes",
    col_names = c("chromosome", "len"),
    show_col_types = FALSE,
    progress = FALSE
  ) |>
    mutate(
      chromosome = gsub("^chr", "", chromosome),
      chr = factor(chromosome, levels = hg19_chroms)
    ) |>
    arrange(chr) |>
    filter(!is.na(chr)) |>
    mutate(g_offset = c(0, cumsum(len))[seq_len(n())]) |>
    select(chromosome, g_offset, len)
}
