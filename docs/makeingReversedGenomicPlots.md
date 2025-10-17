# Creating Reversed Genomic Plots

This document explains how the "reversed" versions of the GISTIC plotting functions differ from their standard counterparts in `R/plot_gistic.R`.

## Overview

The codebase contains two pairs of functions:
1. `create_gistic_Q_plot()` and `create_gistic_Q_plot_reversed()`
2. `create_label_plot()` and `create_label_plot_reversed()`

These create mirror-image plots for genomic data, typically used to show amplifications extending in one direction and deletions extending in the opposite direction.

## GISTIC Q-Value Plot Differences

### The Single Critical Change

The two functions are almost identical except for **one line**:

**Standard version** (line 50):
```r
scale_y_log10(
  expand = c(0, 0, 0, 0),
  breaks = scales::breaks_log(n = 6, base = 10),
  labels = function(x) parse(text = paste0("10^", -round(log10(x), 1)))
)
```

**Reversed version** (lines 97-102):
```r
scale_y_continuous(
  trans = scales::compose_trans("log10", "reverse"),
  expand = c(0, 0, 0, 0),
  breaks = scales::breaks_log(n = 6, base = 10),
  labels = function(x) parse(text = paste0("10^", -round(log10(x), 1)))
)
```

### What `scales::compose_trans("log10", "reverse")` Does

This creates a composite transformation that:
1. **First** applies the log10 transformation
2. **Then** reverses the scale direction

This is necessary because ggplot2 only allows one scale per axis - you cannot chain `scale_y_log10()` and `scale_y_reverse()` separately.

### Visual Effect After coord_flip

Both functions use `coord_flip()` which swaps the x and y axes:

**Standard plot**:
- Before flip: y-axis goes from bottom (low) to top (high) with log scale
- After flip: horizontal axis goes from left (low) to right (high)
- Amplification data extends rightward

**Reversed plot**:
- Before flip: y-axis goes from bottom (HIGH) to top (LOW) due to reverse
- After flip: horizontal axis goes from left (high) to right (low)
- Deletion data extends leftward

### Everything Else Is Identical

Both functions share:
- Same `data_range` calculation
- Same `chrom_panels` creation with chromosome banding
- Same `geom_rect()` for chromosome backgrounds
- Same `geom_step()` for the actual data plot
- Same theming and margin settings
- Same `scale_x_reverse()` for vertical genome positioning

## Label Plot Differences

### Difference 1: Explicit Y Position

**Standard version** (lines 122-125):
```r
peak_labels |>
  slice_min(q_values, n = 30) |>
  arrange(gPos) |>
  ggplot(aes(gPos, Y, label = Label)) +
```

**Reversed version** (lines 154-158):
```r
peak_labels |>
  slice_min(q_values, n = 30) |>
  arrange(gPos) |>
  mutate(Y = 0) |>                    # Forces all anchor points to baseline
  ggplot(aes(gPos, Y, label = Label)) +
```

The reversed version forces all label anchor points to Y = 0, ensuring they start from the same baseline position.

### Difference 2: Label Constraint Region

**Standard version** (line 137):
```r
geom_text_repel(
  ...
  ylim = c(0, 0.95)         # Constrain labels to upper portion
)
```

**Reversed version** (line 170):
```r
geom_text_repel(
  ...
  ylim = c(0.05, 1)         # Constrain labels to lower portion
)
```

The `ylim` parameter constrains where the final labels can be positioned:
- **Standard**: Labels can be placed from 0% to 95% of the y-axis range
- **Reversed**: Labels can be placed from 5% to 100% of the y-axis range

### Combined Visual Effect After coord_flip

After `coord_flip()`, the y-axis becomes horizontal:

**Standard label plot**:
- Label anchors: at varying Y positions (from the data)
- Labels constrained: 0% to 95% of horizontal space
- Result: Labels appear on the left side of the plot

**Reversed label plot**:
- Label anchors: all forced to Y = 0
- Labels constrained: 5% to 100% of horizontal space
- Result: Labels appear on the right side of the plot

## Design Rationale

This pairing creates a symmetrical visualization:

- **Amplification plots** (standard functions):
  - Data extends rightward
  - Labels positioned on the left
  - Pairs: `create_gistic_Q_plot()` + `create_label_plot()`

- **Deletion plots** (reversed functions):
  - Data extends leftward
  - Labels positioned on the right
  - Pairs: `create_gistic_Q_plot_reversed()` + `create_label_plot_reversed()`

This design avoids label collision with the data and creates a visually balanced figure where amplifications and deletions point in opposite directions - a common convention in genomic visualization where these are conceptually opposite biological events.
