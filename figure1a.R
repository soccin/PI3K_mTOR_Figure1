# Load required libraries
library(tidyverse)
library(ggrepel)
library(patchwork)

source("R/load_gistic_data.R")
source("R/utils.R")
source("R/plot_gistic.R")
source("R/load_genome_info.R")
source("R/load_gistic_peaks.R")

# Configuration constants
Q_VALUE_THRESHOLD <- 0.1
TOP_PEAKS_COUNT <- 15

#' Load and process all data for Figure 1
#'
#' @param gistic_file Path to GISTIC results file (mandatory)
#' @param peaks_file Path to peaks CSV file (optional)
#' @return List containing processed amplification data, peak labels, and genome range
load_and_process_data <- function(gistic_file, peaks_file = NULL) {
  # Load genome information
  hg19 <- load_genome_info()
  hg19_gistic <- hg19 |> filter(chromosome %in% 1:22)

  # Load GISTIC amplification data
  gistic_data <- load_gistic_data(gistic_file)

  # Load and process peak labels
  if (is.null(peaks_file) || !file.exists(peaks_file)) {
    # Create empty tibble with appropriate columns if no peaks file
    tbl <- tibble(
      gPos = numeric(0),
      Y = numeric(0),
      Label = character(0),
      q_values = numeric(0),
      Type = character()
    )
    peak_labels <- list(Amp = tbl, Del = tbl)
  } else {
    peak_labels <- load_gistic_peaks(peaks_file) |>
      left_join(hg19) |>
      mutate(gPos = pos + g_offset, Y = 1) |>
      select(gPos, Y, Label = descriptor, q_values, type) |>
      arrange(gPos) |>
      filter(q_values < Q_VALUE_THRESHOLD) |>
      mutate(type = factor(type, levels = c("Amp", "Del"))) %>%
      split(.$type)
  }

  # Calculate genome range for plotting
  last_chrom <- hg19_gistic |> tail(1)
  genome_range <- c(last_chrom$g_offset + last_chrom$len, 0)

  list(
    gistic_data = gistic_data,
    peak_labels = peak_labels,
    genome_range = genome_range
  )
}

# Load data automatically when sourced
# Uses default files from the project
gistic_file <- "iClust_1_scores.gistic"
peaks_file <- "iClust1Peaks.csv"

# Check if files exist
if (!file.exists(gistic_file)) {
  stop(paste("GISTIC file not found:", gistic_file), call. = FALSE)
}

if (!file.exists(peaks_file)) {
  warning(paste("Peaks file not found, proceeding without peak labels:", peaks_file))
  peaks_file <- NULL
}

cat("Loading data from:\n")
cat("  GISTIC file:", gistic_file, "\n")
cat("  Peaks file: ", ifelse(is.null(peaks_file), "(none)", peaks_file), "\n")

# Load data into global environment
data <- load_and_process_data(gistic_file, peaks_file)

# Extract components for easy access
gistic_data <- data$gistic_data
peak_labels <- data$peak_labels
genome_range <- data$genome_range

cat("\nData loaded successfully:\n")
cat("  - gistic_data: Amp and Del data frames\n")
cat("  - peak_labels: Amp and Del peak labels\n")
cat("  - genome_range: Plotting range\n")
cat("\nYou can now work with the plotting functions.\n")
