# Load required libraries
library(tidyverse)
library(ggrepel)
library(patchwork)

source("R/load_gistic_data.R")
source("R/utils.R")
source("R/plot_gistic.R")

# Configuration constants
OUTPUT_FILE <- paste0("fig1_", get_git_label(), ".pdf")
Q_VALUE_THRESHOLD <- 0.1
TOP_PEAKS_COUNT <- 15
PLOT_HEIGHT <- 11
PLOT_WIDTH <- 8.5

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
  amp_data <- gistic_data$Amp |>
    arrange(desc(log10_q_value)) |>
    mutate(
      Label = ifelse(row_number() < TOP_PEAKS_COUNT,
                     sprintf("P%02d", row_number()), "")
    ) |>
    arrange(gPos)

  # Load and process peak labels
  if (is.null(peaks_file) || !file.exists(peaks_file)) {
    # Create empty tibble with appropriate columns if no peaks file
    peak_labels <- tibble(
      gPos = numeric(0),
      Y = numeric(0),
      Label = character(0),
      q_values = numeric(0),
      Type = character()
    )
  } else {
    peak_labels <- read_csv(peaks_file, show_col_types = FALSE) |>
      select(chromosome, pos, Label = descriptor, everything()) |>
      mutate(chromosome = as.character(chromosome)) |>
      left_join(hg19, by = "chromosome") |>
      mutate(
        gPos = pos + g_offset,
        Y = 1
      ) |>
      select(gPos, Y, Label, q_values) |>
      arrange(gPos) |>
      filter(q_values < Q_VALUE_THRESHOLD)
  }

  # Calculate genome range for plotting
  genome_range <- rev(range(c(peak_labels$gPos, amp_data$gPos)))

  list(
    amp_data = amp_data,
    peak_labels = peak_labels,
    genome_range = genome_range
  )
}


# Main execution
main <- function() {
  # Parse command line arguments
  args <- commandArgs(trailingOnly = TRUE)

  if (length(args) < 1) {
    cat("Usage: Rscript figure1.R <GISTIC_FILE> [PEAKS_FILE]\n")
    cat("  GISTIC_FILE: Path to GISTIC results file (mandatory)\n")
    cat("  PEAKS_FILE:  Path to peaks CSV file (optional)\n")
    cat("\nExample:\n")
    cat("  Rscript figure1.R iClust_1_scores.gistic\n")
    cat("  Rscript figure1.R iClust_1_scores.gistic iClust1Peaks.csv\n")
    stop("Missing required argument: GISTIC_FILE", call. = FALSE)
  }

  gistic_file <- args[1]
  peaks_file <- if (length(args) >= 2) args[2] else NULL

  # Check if mandatory file exists
  if (!file.exists(gistic_file)) {
    stop(paste("GISTIC file not found:", gistic_file), call. = FALSE)
  }

  # Check optional peaks file if provided
  if (!is.null(peaks_file) && !file.exists(peaks_file)) {
    warning(paste("Peaks file not found, proceeding without peak labels:", peaks_file))
    peaks_file <- NULL
  }

  cat("Processing with:\n")
  cat("  GISTIC file:", gistic_file, "\n")
  cat("  Peaks file: ", ifelse(is.null(peaks_file), "(none)", peaks_file), "\n")

  create_figure1(gistic_file, peaks_file)
}

# Run if script is executed directly
if (sys.nframe() == 0) {
  main()
}