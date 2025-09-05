# Load required libraries
library(tidyverse)
library(ggrepel)
library(patchwork)

source("R/load_gistic_data.R")
source("R/utils.R")

# Configuration constants
GISTIC_FILE <- "iClust_1_scores.gistic"
PEAKS_FILE <- "iClust1Peaks.csv"
OUTPUT_FILE <- paste0("figure1_", get_git_label(), ".pdf")
Q_VALUE_THRESHOLD <- 0.1
TOP_PEAKS_COUNT <- 15
PLOT_HEIGHT <- 11
PLOT_WIDTH <- 8.5

#' Load and process all data for Figure 1
#' 
#' @return List containing processed amplification data, peak labels, and genome range
load_and_process_data <- function() {
  # Load genome information
  hg19 <- load_genome_info()
  hg19_gistic <- hg19 |> filter(chromosome %in% 1:22)
  
  # Load GISTIC amplification data
  gistic_data <- load_gistic_data(GISTIC_FILE)
  amp_data <- gistic_data$Amp |>
    arrange(desc(log10_q_value)) |>
    mutate(
      Label = ifelse(row_number() < TOP_PEAKS_COUNT, 
                     sprintf("P%02d", row_number()), "")
    ) |>
    arrange(gPos)
  
  # Load and process peak labels
  peak_labels <- read_csv(PEAKS_FILE, show_col_types = FALSE) |>
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
  
  # Calculate genome range for plotting
  genome_range <- rev(range(c(peak_labels$gPos, amp_data$gPos)))
  
  list(
    amp_data = amp_data,
    peak_labels = peak_labels,
    genome_range = genome_range
  )
}

#' Create amplification step plot
#' 
#' @param amp_data Data frame with amplification data
#' @param genome_range Numeric vector with genome plotting range
#' @return ggplot object
create_amplification_plot <- function(amp_data, genome_range) {
  ggplot(amp_data, aes(gPos, 10^(log10_q_value))) +
    geom_step(color = "darkred") +
    theme_light() +
    scale_y_log10(expand = c(0, 0, 0.01, 0)) +
    coord_flip(clip = "off") +
    scale_x_reverse(limits = genome_range, expand = c(0, 0, 0, 0)) +
    theme(
      axis.text.y = element_blank(),
      axis.ticks = element_blank(),
      axis.title = element_blank(),
      plot.margin = margin(10, 10, 0, 0, "pt"),
      panel.spacing = unit(0, "pt")
    )
}

#' Create peak labels plot with optimized text repel
#' 
#' @param peak_labels Data frame with peak label data
#' @param genome_range Numeric vector with genome plotting range
#' @return ggplot object
create_label_plot <- function(peak_labels, genome_range) {
  peak_labels |>
    arrange(gPos) |>
    ggplot(aes(gPos, Y, label = Label)) +
    theme_void() +
    geom_text_repel(
      max.overlaps = Inf,
      min.segment.length = 0,
      segment.curvature = -1e-20,
      max.iter = 10000,         # High iteration count for better positioning
      max.time = 3,             # More time to optimize label placement
      force = 1.2,
      seed = 42,                # Reproducible results
      segment.color = "black",
      segment.size = 0.3,
      ylim = c(0, 0.95)         # Constrain labels to upper portion
    ) +
    coord_flip(clip = "off") +
    scale_x_reverse(limits = genome_range, expand = c(0, 0, 0, 0)) +
    scale_y_continuous(limits = c(0, 1), expand = c(0, 0)) +
    theme(plot.margin = margin(10, 0, 0, 0, "pt"))
}

#' Create and save Figure 1
#' 
#' @param output_file Path to output PDF file
create_figure1 <- function(output_file = OUTPUT_FILE) {
  data <- load_and_process_data()
  
  # Create individual plots
  label_plot <- create_label_plot(data$peak_labels, data$genome_range)
  amp_plot <- create_amplification_plot(data$amp_data, data$genome_range)
  
  # Combine plots using patchwork
  combined_plot <- label_plot | amp_plot
  
  # Save to PDF
  pdf(file = output_file, height = PLOT_HEIGHT, width = PLOT_WIDTH)
  print(combined_plot)
  dev.off()
  
  message("Figure 1 saved to: ", output_file)
}

# Main execution
main <- function() {
  create_figure1()
}

# Run if script is executed directly
if (sys.nframe() == 0) {
  main()
}