# GISTIC plotting functions for Figure 1
# Contains visualization functions for amplification data and peak labels

library(ggplot2)
library(ggrepel)
library(patchwork)

#' Create and save Figure 1
#'
#' @param gistic_file Path to GISTIC results file (mandatory)
#' @param peaks_file Path to peaks CSV file (optional)
#' @param output_file Path to output PDF file
create_figure1 <- function(gistic_file, peaks_file = NULL, output_file = OUTPUT_FILE) {
  data <- load_and_process_data(gistic_file, peaks_file)

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

#' Create amplification step plot
#'
#' @param amp_data Data frame with amplification data
#' @param genome_range Numeric vector with genome plotting range
#' @return ggplot object
create_amplification_plot <- function(amp_data, genome_range) {
  ggplot(amp_data, aes(gPos, 10^(log10_q_value))) +
    geom_step(color = "darkred") +
    theme_light() +
    scale_y_log10(
      expand = c(0, 0, 0.01, 0),
      breaks = scales::breaks_log(n = 6, base = 10),
      labels = function(x) parse(text = paste0("10^", -round(log10(x), 1)))
    ) +
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

