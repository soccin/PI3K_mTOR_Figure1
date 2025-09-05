# Figure 1: Genomic Amplification Analysis

This repository contains R code to generate Figure 1 for the PI3K/mTOR manuscript, which visualizes genomic amplification patterns using GISTIC (Genomic Identification of Significant Targets in Cancer) results.

## Overview

The figure shows:
- **Left panel**: Peak region labels with optimized text positioning
- **Right panel**: Step plot of amplification significance scores across the genome

## Files and Structure

```
├── figure1.R                  # Main script - refactored and modular
├── R/
│   ├── load_genome_info.R    # Loads hg19 chromosome information
│   └── load_gistic_data.R    # Processes GISTIC amplification data
├── hg19.chrom.sizes          # Reference genome chromosome sizes
├── iClust_1_scores.gistic    # GISTIC results (amplifications/deletions)
├── iClust1Peaks.csv          # Significant peak regions with q-values
├── attic/                    # Development/experimental code
└── info/                     # Reference documents and figures
```

## Dependencies

Required R packages:
- `tidyverse` - Data manipulation and ggplot2 visualization
- `ggrepel` - Intelligent text label positioning
- `patchwork` - Plot composition
- `janitor` - Data cleaning utilities

Install missing packages:
```r
install.packages(c("tidyverse", "ggrepel", "patchwork", "janitor"))
```

## Usage

### Quick Start
```r
source("figure1.R")
```

This generates `test02.pdf` with the complete Figure 1.

### Advanced Usage
```r
# Load libraries and functions
library(tidyverse)
library(ggrepel)
library(patchwork)
source("R/load_gistic_data.R")

# Load and process all data
data <- load_and_process_data()

# Create individual plot components
label_plot <- create_label_plot(data$peak_labels, data$genome_range)
amp_plot <- create_amplification_plot(data$amp_data, data$genome_range)

# Generate figure with custom output file
create_figure1("custom_figure1.pdf")
```

## Configuration

Key parameters can be modified in `figure1.R`:

- `Q_VALUE_THRESHOLD = 0.1` - Significance threshold for peak filtering
- `TOP_PEAKS_COUNT = 15` - Number of top peaks to label in amplification plot
- `PLOT_HEIGHT = 11`, `PLOT_WIDTH = 8.5` - PDF dimensions (inches)

## Data Processing Pipeline

1. **Genome coordinates**: Chromosome positions converted to genome-wide coordinates using cumulative offsets
2. **GISTIC data**: Amplification/deletion scores loaded and joined with genome info
3. **Peak filtering**: Only peaks with q-values < 0.1 included
4. **Label optimization**: `geom_text_repel()` with high iteration counts for optimal positioning
5. **Plot combination**: `patchwork` combines label and amplification panels

## Output

- **Format**: PDF (11" × 8.5")
- **Layout**: Two-panel horizontal layout
- **Quality**: Publication-ready with optimized label positioning

## Code Architecture

### Functions

- `load_and_process_data()` - Data loading, processing, and filtering
- `create_amplification_plot()` - GISTIC amplification step plot
- `create_label_plot()` - Peak labels with text repel optimization
- `create_figure1()` - Plot composition and PDF output
- `main()` - Entry point for script execution

### Design Principles

- **Modular**: Clean function separation for maintainability
- **Configurable**: Constants defined at top of script
- **Tidyverse**: Consistent pipe-based data processing
- **Reproducible**: Fixed random seed for label positioning
- **Documented**: Comprehensive roxygen2 documentation

## Development

The code has been refactored from the original monolithic script to follow modern R/tidyverse best practices:

- ✅ Function-based modular architecture
- ✅ Comprehensive documentation
- ✅ Configuration constants extracted
- ✅ Consistent coding style
- ✅ Removed experimental code clutter

## Troubleshooting

**Common Issues:**

1. **Missing `get_script_dir()` function**: This function should be defined in your `~/.Rprofile`
2. **Package loading errors**: Install missing dependencies listed above
3. **File path issues**: Ensure all data files are in the correct locations
4. **Memory issues**: Large GISTIC files may require more RAM

## Citation

Generated for PI3K/mTOR manuscript, 2023-05-30.