# Load required libraries
library(tidyverse)
library(ggrepel)
library(patchwork)

# Source helper functions
source("R/load_gistic_data.R")
source("R/utils.R")
source("R/plot_gistic.R")
source("R/plot_gistic_2.R")
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
    empty_tbl <- tibble(
      gPos = numeric(0),
      Y = numeric(0),
      Label = character(0),
      q_values = numeric(0),
      Type = character()
    )
    peak_labels <- list(Amp = empty_tbl, Del = empty_tbl)
  } else {
    peak_labels <- load_gistic_peaks(peaks_file) |>
      left_join(hg19) |>
      mutate(gPos = pos + g_offset, Y = 1) |>
      select(gPos, Y, Label = descriptor, q_values, type) |>
      arrange(gPos) |>
      filter(q_values < Q_VALUE_THRESHOLD) |>
      mutate(type = factor(type, levels = c("Amp", "Del"))) %>%
      split(.$type)  # Need %>% here - split(.$type) doesn't work with |>
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

# ============================================================================
# Command Line Argument Parsing
# ============================================================================

# Parse command line arguments
argv <- commandArgs(trailingOnly = TRUE)

# Extract optional TITLE parameter (format: TITLE=value)
TITLE <- ""
title_argv <- grep("^TITLE=", argv)
if (length(title_argv) > 0) {
  title_arg <- argv[title_argv[1]]
  TITLE <- sub("^TITLE=", "", title_arg)
  argv <- argv[-title_argv]  # Remove TITLE from remaining args
}

# Validate arguments and show usage if needed
if (length(argv) < 1) {
  cat("Usage: Rscript figure1a.R [TITLE=<title>] <GISTIC_FILE> [PEAKS_FILE]\n")
  cat("  TITLE:       Optional title parameter (e.g., TITLE=iClust1)\n")
  cat("  GISTIC_FILE: Path to GISTIC results file (mandatory)\n")
  cat("  PEAKS_FILE:  Path to peaks CSV file (optional)\n")
  cat("\nExample:\n")
  cat("  Rscript figure1a.R iClust_1_scores.gistic\n")
  cat("  Rscript figure1a.R TITLE=iClust1 iClust_1_scores.gistic iClust1Peaks.csv\n")
  stop("Missing required argument: GISTIC_FILE", call. = FALSE)
}

# Extract file paths from remaining arguments
gistic_file <- argv[1]
peaks_file <- if (length(argv) >= 2) argv[2] else NULL

# Validate file paths
if (!file.exists(gistic_file)) {
  stop(paste("GISTIC file not found:", gistic_file), call. = FALSE)
}

if (!is.null(peaks_file) && !file.exists(peaks_file)) {
  warning(paste("Peaks file not found, proceeding without peak labels:",
                peaks_file))
  peaks_file <- NULL
}

# ============================================================================
# Data Loading
# ============================================================================

cat("Loading data from:\n")
cat("  Title:      ", ifelse(TITLE == "", "(none)", TITLE), "\n")
cat("  GISTIC file:", gistic_file, "\n")
cat("  Peaks file: ", ifelse(is.null(peaks_file), "(none)", peaks_file), "\n")

data <- load_and_process_data(gistic_file, peaks_file)

# Extract components for easier access
gistic_data <- data$gistic_data
peak_labels <- data$peak_labels
genome_range <- data$genome_range

cat("\nData loaded successfully:\n")
cat("  - gistic_data: Amp and Del data frames\n")
cat("  - peak_labels: Amp and Del peak labels\n")
cat("  - genome_range: Plotting range\n")

# ============================================================================
# Plot Generation
# ============================================================================

PLOT_HEIGHT <- 11
PLOT_WIDTH <- 8.5

# Create individual plot components
amp_labels <- create_label_plot(peak_labels$Amp, genome_range)
del_labels <- create_label_plot_reversed(peak_labels$Del, genome_range)
gistic_plot <- gistic_q2_plot(gistic_data, genome_range) + ggtitle(TITLE)

# Combine plots: amplification labels | GISTIC scores | deletion labels
combined_plot <- amp_labels | gistic_plot | del_labels

# Generate output filename with sanitized title and git version
clean_title <- gsub("[^A-Za-z0-9]", "_", TITLE)
output_file <- paste0("figB_", clean_title, "_", get_git_label(), ".pdf")

# Save combined plot to PDF
pdf(file = output_file, height = PLOT_HEIGHT, width = PLOT_WIDTH)
print(combined_plot)
dev.off()

