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

#' Create and save Figure 1
#'
#' @param gistic_file Path to GISTIC results file (mandatory)
#' @param peaks_file Path to peaks CSV file (optional)
#' @param TITLE Optional title prefix for plots
#' @param output_file Path to output PDF file
create_figure1 <- function(gistic_file, peaks_file = NULL, TITLE = "", output_file = OUTPUT_FILE) {
  data <- load_and_process_data(gistic_file, peaks_file)

  # Create individual plots
  amp_label_plot <- create_label_plot(data$peak_labels$Amp, data$genome_range)
  amp_plot <- create_amplification_plot(data$gistic_data$Amp, data$genome_range, TITLE)

  del_label_plot <- create_label_plot(data$peak_labels$Del, data$genome_range)
  del_plot <- create_deletion_plot(data$gistic_data$Del, data$genome_range, TITLE)

  # Combine plots using patchwork
  combined_amp_plot <- amp_label_plot | amp_plot
  combined_del_plot <- del_label_plot | del_plot

  # Save to PDF
  pdf(file = output_file, height = PLOT_HEIGHT, width = PLOT_WIDTH)
  print(combined_amp_plot)
  print(combined_del_plot)
  dev.off()

  message("Figure 1 saved to: ", output_file)
}


# Main execution
main <- function(argv) {
  # Parse command line arguments

  # Initialize TITLE variable
  TITLE <<- ""

  # Check for TITLE parameter and remove from argv
  title_argv <- grep("^TITLE=", argv)
  if (length(title_argv) > 0) {
    title_arg <- argv[title_argv[1]]
    TITLE <<- sub("^TITLE=", "", title_arg)
    argv <- argv[-title_argv]
  }

  if (length(argv) < 1) {
    cat("Usage: Rscript figure1.R [TITLE=<title>] <GISTIC_FILE> [PEAKS_FILE]\n")
    cat("  TITLE:       Optional title parameter (e.g., TITLE=iClust1)\n")
    cat("  GISTIC_FILE: Path to GISTIC results file (mandatory)\n")
    cat("  PEAKS_FILE:  Path to peaks CSV file (optional)\n")
    cat("\nExample:\n")
    cat("  Rscript figure1.R iClust_1_scores.gistic\n")
    cat("  Rscript figure1.R TITLE=iClust1 iClust_1_scores.gistic iClust1Peaks.csv\n")
    stop("Missing required argument: GISTIC_FILE", call. = FALSE)
  }

  gistic_file <- argv[1]
  peaks_file <- if (length(argv) >= 2) argv[2] else NULL

  # Check if mandatory file exists
  if (!file.exists(gistic_file)) {
    stop(paste("GISTIC file not found:", gistic_file), call. = FALSE)
  }

  # Check optional peaks file if provided
  if (!is.null(peaks_file) && !file.exists(peaks_file)) {
    warning(paste("Peaks file not found, proceeding without peak labels:", peaks_file))
    peaks_file <- NULL
  }

  # Generate output filename based on TITLE
  if (TITLE != "") {
    # Sanitize TITLE for filename (replace spaces and special chars with underscores)
    clean_title <- gsub("[^A-Za-z0-9]", "_", TITLE)
    output_file <- paste0("fig1_", clean_title, "_", get_git_label(), ".pdf")
  } else {
    output_file <- OUTPUT_FILE
  }

  cat("Processing with:\n")
  cat("  Title:      ", ifelse(TITLE == "", "(none)", TITLE), "\n")
  cat("  GISTIC file:", gistic_file, "\n")
  cat("  Peaks file: ", ifelse(is.null(peaks_file), "(none)", peaks_file), "\n")
  cat("  Output file:", output_file, "\n")

  create_figure1(gistic_file, peaks_file, TITLE, output_file)
}

argv <- commandArgs(trailingOnly = TRUE)

# Run if script is executed directly
if (sys.nframe() == 0) {
  main(argv)
}
