# GISTIC plotting functions for Figure 1
# Contains visualization functions for amplification data and peak labels

library(ggplot2)
library(ggrepel)
library(patchwork)


#' GISTIC Q2 Plots both amplifications and deletions together
#'
#' dq is a list of: Amp and Del GISTIC Q profiles

gistic_Q2_plot <- function(dq, genome_range) {

  data_range=range(10^unlist(map(dq,"log10_q_value")))
  data_range[2]=10^ceiling(log10(data_range[2])*1.05)
  data_range[2]=10^36
  dq$Del=dq$Del %>% mutate(reverse_Q=log10(data_range[2])-log10_q_value)

  chrom_panels  <- load_genome_info() |>
    filter(chromosome %in% 1:22) |>
    mutate(
      xmin = g_offset, xmax = g_offset + len,
      ymin = data_range[1], ymax = data_range[2],
      color = factor((row_number() - 1) %% 2 + 1)
    )

  y_breaks=scales::breaks_log(n = 6, base = 10)(data_range)

  p0=ggplot() +
    theme_light() +
    geom_rect(
      data = chrom_panels,
      aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = color),
      inherit.aes = FALSE,
      alpha = 0.35
    ) +
    scale_fill_manual(values = c("white", "grey65"), guide = "none")

  p1=p0 +
    geom_step(data=dq$Amp,aes(gPos,10^log10_q_value),color="darkred") +
    geom_step(data=dq$Del,aes(gPos,10^reverse_Q),color="darkblue") +
    scale_y_log10(
      expand = c(0.01, 0, 0.01, 0),
      breaks = y_breaks,
      labels = function(x) parse(text = paste0("10^", -round(log10(x), 1))),
      sec.axis = sec_axis(~(data_range[2]/data_range[1])/.,
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
