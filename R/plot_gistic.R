# GISTIC plotting functions for Figure 1
# Contains visualization functions for amplification data and peak labels

library(ggplot2)
library(ggrepel)
library(patchwork)

#' Create amplification step plot
#'
#' @param amp_data Data frame with amplification data
#' @param genome_range Numeric vector with genome plotting range
#' @param title Optional title prefix
#' @return ggplot object
create_amplification_plot <- function(amp_data, genome_range, title = "") {
  plot_title <- if (title == "") "Amplification" else paste(title, "Amplification")
  create_gistic_Q_plot(amp_data, genome_range, "darkred") + labs(title = plot_title)
}

#' Create deletion step plot
#'
#' @param del_data Data frame with deletion data
#' @param genome_range Numeric vector with genome plotting range
#' @param title Optional title prefix
#' @return ggplot object
create_deletion_plot <- function(del_data, genome_range, title = "") {
  plot_title <- if (title == "") "Deletion" else paste(title, "Deletion")
  create_gistic_Q_plot_reversed(del_data, genome_range, "darkblue") + labs(title = plot_title)
}

create_gistic_Q_plot <- function(data, genome_range, color) {
  data_range <- range(10^data$log10_q_value)
  chrom_panels  <- load_genome_info() |>
    filter(chromosome %in% 1:22) |>
    mutate(
      xmin = g_offset, xmax = g_offset + len,
      ymin = data_range[1], ymax = (10^0.1) * data_range[2],
      color = factor((row_number() - 1) %% 2 + 1)
    )

  ggplot(data, aes(gPos, 10^(log10_q_value))) +
    theme_light() +
    geom_rect(
      data = chrom_panels,
      aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = color),
      inherit.aes = FALSE,
      alpha = 0.35
    ) +
    scale_fill_manual(values = c("white", "grey65"), guide = "none") +
    geom_step(color = color) +
    scale_y_log10(
      expand = c(0, 0, 0, 0),
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
      panel.spacing = unit(0, "pt"),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank()
    )
}

#' Create GISTIC Q-value plot with reversed horizontal axis
#'
#' Transparent overlay version designed to be superimposed on create_gistic_Q_plot.
#' All backgrounds are transparent except for the step line.
#' After coord_flip, horizontal axis goes from right (high values) to left (low values).
#' Axis labels are positioned at the top of the plot.
#'
#' @param data Data frame with log10_q_value and gPos columns
#' @param genome_range Numeric vector with genome plotting range
#' @param color Color for the step plot line
#' @return ggplot object (transparent, suitable for overlay)
create_gistic_Q_plot_reversed <- function(data, genome_range, color) {
  ggplot(data, aes(gPos, 10^(log10_q_value))) +
    theme_light() +
    geom_step(color = color) +
    scale_y_continuous(
      trans = scales::compose_trans("log10", "reverse"),
      expand = c(0, 0, 0, 0),
      breaks = scales::breaks_log(n = 6, base = 10),
      labels = function(x) parse(text = paste0("10^", -round(log10(x), 1))),
      position = "right"
    ) +
    coord_flip(clip = "off") +
    scale_x_reverse(limits = genome_range, expand = c(0, 0, 0, 0)) +
    theme(
      axis.text.x.top = element_text(),
      axis.text.y = element_blank(),
      axis.ticks = element_blank(),
      axis.title = element_blank(),
      plot.margin = margin(10, 10, 0, 0, "pt"),
      panel.spacing = unit(0, "pt"),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.background = element_rect(fill = "transparent", color = NA),
      plot.background = element_rect(fill = "transparent", color = NA),
      panel.border = element_blank()
    )
}

#' Create peak labels plot with optimized text repel
#'
#' @param peak_labels Data frame with peak label data
#' @param genome_range Numeric vector with genome plotting range
#' @return ggplot object
create_label_plot <- function(peak_labels, genome_range) {
  peak_labels |>
    slice_min(q_values, n = 30) |>
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

#' Create peak labels plot with reversed horizontal axis (labels on right)
#'
#' Pairs with create_gistic_Q_plot_reversed() to create labels positioned to the right
#' of the plot, with label segments pointing from right to left.
#'
#' @param peak_labels Data frame with peak label data
#' @param genome_range Numeric vector with genome plotting range
#' @return ggplot object
create_label_plot_reversed <- function(peak_labels, genome_range) {
  peak_labels |>
    slice_min(q_values, n = 30) |>
    arrange(gPos) |>
    mutate(Y = 0) |>
    ggplot(aes(gPos, Y, label = Label)) +
    theme_void() +
    geom_text_repel(
      max.overlaps = Inf,
      min.segment.length = 0,
      segment.curvature = -1e-20,
      max.iter = 10000,
      max.time = 3,
      force = 1.2,
      seed = 42,
      segment.color = "black",
      segment.size = 0.3,
      ylim = c(0.05, 1)
    ) +
    coord_flip(clip = "off") +
    scale_x_reverse(limits = genome_range, expand = c(0, 0, 0, 0)) +
    scale_y_continuous(limits = c(0, 1), expand = c(0, 0)) +
    theme(plot.margin = margin(10, 0, 0, 0, "pt"))
}