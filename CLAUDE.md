# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a manuscript figure generation project that creates Figure 1 visualizations using R. The project analyzes genomic amplification data from GISTIC (Genomic Identification of Significant Targets in Cancer) results and creates publication-quality plots showing genomic regions of interest.

## Key Files and Data Structure

- `figure1.R` - Main script that generates Figure 1 plots
- `R/load_gistic_data.R` - Loads and processes GISTIC amplification/deletion data
- `R/load_genome_info.R` - Loads human genome (hg19) chromosome information and calculates genome-wide positions
- `hg19.chrom.sizes` - Reference file with chromosome sizes for hg19 genome build
- `iClust_1_scores.gistic` - GISTIC results file with amplification/deletion scores
- `iClust1Peaks.csv` - Peak regions of interest with q-values and genomic coordinates
- `attic/` - Contains experimental/development versions of plots

## Data Processing Architecture

The code follows a modular approach:

1. **Genome coordinate transformation**: `load_genome_info()` converts chromosome positions to genome-wide coordinates using cumulative chromosome offsets
2. **GISTIC data loading**: `load_gistic_data()` reads GISTIC results and joins with genome info to create plottable coordinates
3. **Plot generation**: Main script creates two-panel plots using `patchwork` - amplification scores (step plot) and labeled peak regions (text repel labels)

## Dependencies

Required R packages:
- tidyverse (data manipulation and ggplot2)
- ggrepel (label positioning to avoid overlaps)
- patchwork (plot composition)
- readr (file reading)
- dplyr (data manipulation)
- janitor (data cleaning)

## Common Development Commands

To run the main figure generation:
```r
source("figure1.R")
```

Or run specific functions:
```r
# Load libraries and source functions
library(tidyverse)
library(ggrepel) 
library(patchwork)
source("R/load_gistic_data.R")

# Run individual components
data <- load_and_process_data()
label_plot <- create_label_plot(data$peak_labels, data$genome_range)
amp_plot <- create_amplification_plot(data$amp_data, data$genome_range)
create_figure1("custom_output.pdf")
```

The script outputs `test02.pdf` containing the combined amplification plot with labeled peaks.

## Code Architecture Notes

### Refactored Structure
The code is now organized into clean, modular functions:

- `load_and_process_data()`: Handles all data loading, processing, and filtering
- `create_amplification_plot()`: Creates the GISTIC amplification step plot 
- `create_label_plot()`: Creates the peak labels plot with optimized text repel
- `create_figure1()`: Combines plots and handles PDF output
- `main()`: Entry point function

### Technical Details
- **Coordinate system**: All genomic positions are converted to genome-wide coordinates (gPos) by adding chromosome offsets
- **Plot composition**: Uses patchwork syntax `label_plot | amp_plot` to combine panels
- **Label optimization**: Uses `geom_text_repel()` with high iteration counts (10,000) and time limits (3s) for optimal label placement
- **Data filtering**: Only peaks with q-values < 0.1 are included in visualizations
- **Configuration**: All constants (file paths, thresholds, plot dimensions) are defined at the top of the script

## Development Notes

- The `attic/` directory contains experimental versions showing the iterative development of label positioning
- Plot margins and spacing are carefully tuned for publication quality
- Uses `coord_flip()` to create vertical genome plots with chromosomes ordered top to bottom
- The `get_script_dir()` function referenced in load_gistic_data.R appears to be missing but the code structure suggests it should resolve to the project root