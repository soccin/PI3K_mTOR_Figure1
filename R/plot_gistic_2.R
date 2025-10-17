# GISTIC plotting functions for Figure 1
# Contains visualization functions for amplification and deletion data

library(ggplot2)
library(ggrepel)
library(patchwork)

#' Create GISTIC Q-value plot with amplifications and deletions
#'
#' Generates a dual-axis plot showing both amplification (top) and deletion
#' (bottom) GISTIC Q-values across the genome. Deletions are reversed on
#' the y-axis to create a mirror plot.
#'
#' @param dq List with two elements: Amp and Del, each containing GISTIC
#'   Q profiles with columns gPos and log10_q_value
#' @param genome_range Numeric vector of length 2 specifying the genomic
#'   coordinate range to plot
#'
#' @return A ggplot object with the combined amplification/deletion plot
gistic_q2_plot <- function(dq, genome_range) {

  # Calculate data range for y-axis from both amp and del data
  data_range <- range(10^unlist(map(dq, "log10_q_value")))
  data_range[2] <- 10^ceiling(log10(data_range[2]) * 1.05)
  data_range[2] <- 10^36

  # Transform deletion data to reversed scale for mirrored display
  dq$Del <- dq$Del |>
    mutate(reverse_q = log10(data_range[2]) - log10_q_value)

  # Create chromosome background panels
  chrom_panels <- load_genome_info() |>
    filter(chromosome %in% 1:22) |>
    mutate(
      xmin = g_offset,
      xmax = g_offset + len,
      ymin = data_range[1],
      ymax = data_range[2],
      color = factor((row_number() - 1) %% 2 + 1)
    )

  # Calculate logarithmic y-axis breaks
  y_breaks <- scales::breaks_log(n = 6, base = 10)(data_range)

  # Build base plot with chromosome backgrounds
  p0 <- ggplot() +
    theme_light() +
    geom_rect(
      data = chrom_panels,
      aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = color),
      inherit.aes = FALSE,
      alpha = 0.35
    ) +
    scale_fill_manual(values = c("white", "grey65"), guide = "none")

  # Add amplification and deletion traces with dual axes
  p1 <- p0 +
    geom_step(
      data = dq$Amp,
      aes(gPos, 10^log10_q_value),
      color = "darkred"
    ) +
    geom_step(
      data = dq$Del,
      aes(gPos, 10^reverse_q),
      color = "darkblue"
    ) +
    scale_y_log10(
      expand = c(0.01, 0, 0.01, 0),
      breaks = y_breaks,
      labels = function(x) parse(text = paste0("10^", -round(log10(x), 1))),
      sec.axis = sec_axis(
        ~ (data_range[2] / data_range[1]) / .,
        breaks = y_breaks,
        labels = function(x) parse(text = paste0("10^", -round(log10(x), 1)))
      )
    ) +
    coord_flip(clip = "off") +
    scale_x_reverse(limits = genome_range, expand = c(0, 0, 0, 0)) +
    theme(
      axis.text.y = element_blank(),
      axis.ticks = element_blank(),
      axis.title = element_blank(),
      plot.margin = margin(10, 10, 0, 0, "pt"),
      panel.spacing = unit(0, "pt"),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank()
    )

  p1

}
