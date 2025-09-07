# PI3K/mTOR Figure 1: GISTIC Copy Number Analysis

**Version**: v1.0.1

[![GitHub](https://img.shields.io/badge/GitHub-soccin%2FPI3K__mTOR__Figure1-blue)](https://github.com/soccin/PI3K_mTOR_Figure1)

This repository generates **Figure 1** for the PI3K/mTOR manuscript, visualizing genomic copy number alterations using GISTIC (Genomic Identification of Significant Targets in Cancer) analysis results. The figure displays both amplifications and deletions across the human genome with publication-quality formatting.

## Features

- **Dual-panel visualization**: Amplification and deletion plots in a single figure
- **Command-line interface**: Flexible execution with optional parameters
- **Git-versioned outputs**: Reproducible filenames with version tracking
- **Publication-ready**: High-quality PDF output optimized for manuscripts
- **Modular architecture**: Clean, documented, and maintainable R code
- **Comprehensive data support**: Handles both GISTIC scores and peak lesions

## Quick Start

```bash
# Basic usage - generates both amplification and deletion plots
Rscript figure1.R iClust_1_scores.gistic iClust_1_all_lesions.conf_99.txt

# With custom title
Rscript figure1.R TITLE=iClust1 iClust_1_scores.gistic iClust_1_all_lesions.conf_99.txt

# GISTIC data only (no peak labels)
Rscript figure1.R iClust_1_scores.gistic
```

**Output**: `fig1_v0.1.3-devs-{commit}.pdf` (git-versioned filename)

## Project Structure

```
.
├── figure1.R                           # Main script with command-line interface
├── R/                                  # Modular R functions
│   ├── load_genome_info.R              # hg19 chromosome reference data
│   ├── load_gistic_data.R              # GISTIC scores processing
│   ├── load_gistic_peaks.R             # Peak lesions data processing
│   ├── plot_gistic.R                   # Visualization functions
│   └── utils.R                         # Git labeling utilities
├── hg19.chrom.sizes                    # Human genome reference (93 entries)
├── iClust_1_scores.gistic              # GISTIC amplification/deletion scores (26K+ entries)
├── iClust_1_all_lesions.conf_99.txt    # Significant peaks with metadata (323 entries)
├── attic/                              # Development/experimental code
├── info/                               # Reference documents
└── CLAUDE.md                           # Development guidelines
```

## Data Files

| File | Format | Lines | Description |
|------|--------|-------|-------------|
| `iClust_1_scores.gistic` | TSV | 26,228 | GISTIC amplification/deletion significance scores across genome |
| `iClust_1_all_lesions.conf_99.txt` | TSV | 323 | Significant copy number peaks with coordinates, q-values, and sample data |
| `hg19.chrom.sizes` | TSV | 93 | Human genome build hg19 chromosome lengths |

### Data Format Examples

**GISTIC Scores** (iClust_1_scores.gistic):
```
Type    Chromosome  Start     End       -log10(q-value)  G-score   average amplitude  frequency
Amp     1           746608    776307    0.162544         0.438219  0.485431          0.400000
Del     1           850000    900000    1.523421         -0.234567 -0.312456         0.350000
```

**Peak Lesions** (iClust_1_all_lesions.conf_99.txt):
```
Unique Name              Descriptor  Peak Limits                      q values    [Sample columns...]
Amplification Peak  1    1p32.1      chr1:59678281-60171523          0.0063925   [Sample data...]
Deletion Peak  1         1p36.13     chr1:17088415-17214110          0.083894    [Sample data...]
```

## Dependencies

### Required R Packages
```r
install.packages(c(
  "tidyverse",    # Data manipulation and ggplot2
  "ggrepel",      # Intelligent label positioning
  "patchwork",    # Multi-panel plot composition
  "janitor",      # Data cleaning utilities
  "git2r"         # Git integration for versioning
))
```

### System Requirements
- **R** ≥ 4.0.0
- **Memory**: ~2GB RAM (for large GISTIC files)
- **Output**: PDF generation capabilities

## Usage

### Command Line Interface

```bash
Rscript figure1.R [TITLE=<title>] <GISTIC_FILE> [PEAKS_FILE]
```

**Parameters:**
- `TITLE=<text>`: Optional title prefix for plot panels
- `GISTIC_FILE`: Path to GISTIC results file (mandatory)
- `PEAKS_FILE`: Path to peaks/lesions file (optional)

**Examples:**
```bash
# Minimal usage
Rscript figure1.R iClust_1_scores.gistic

# With peak labels
Rscript figure1.R iClust_1_scores.gistic iClust_1_all_lesions.conf_99.txt

# With custom title
Rscript figure1.R TITLE="iClust Subtype 1" iClust_1_scores.gistic iClust_1_all_lesions.conf_99.txt
```

### Programmatic Usage

```r
# Load libraries and source functions
library(tidyverse)
library(ggrepel)
library(patchwork)
source("figure1.R")

# Generate figure with custom parameters
create_figure1(
  gistic_file = "iClust_1_scores.gistic",
  peaks_file = "iClust_1_all_lesions.conf_99.txt",
  TITLE = "Custom Analysis",
  output_file = "custom_figure.pdf"
)
```

## Configuration

Key parameters in `figure1.R`:

```r
# Output and processing settings
OUTPUT_FILE <- paste0("fig1_", get_git_label(), ".pdf")  # Git-versioned filename
Q_VALUE_THRESHOLD <- 0.1        # Significance threshold for peak filtering
TOP_PEAKS_COUNT <- 15           # Number of top peaks for labeling
PLOT_HEIGHT <- 11               # PDF height (inches)
PLOT_WIDTH <- 8.5               # PDF width (inches)
```

## Functions & Architecture

### Core Functions

| Function | Module | Purpose |
|----------|--------|---------|
| `load_and_process_data()` | figure1.R | Master data loading and processing |
| `create_figure1()` | figure1.R | Plot generation and PDF output |
| `load_gistic_data()` | load_gistic_data.R | Process GISTIC significance scores |
| `load_gistic_peaks()` | load_gistic_peaks.R | Process peak lesions data |
| `create_amplification_plot()` | plot_gistic.R | Generate amplification visualization |
| `create_deletion_plot()` | plot_gistic.R | Generate deletion visualization |
| `create_label_plot()` | plot_gistic.R | Peak label positioning with ggrepel |
| `load_genome_info()` | load_genome_info.R | hg19 chromosome coordinates |
| `get_git_label()` | utils.R | Git-based version labeling |

### Data Processing Pipeline

1. **Genome Coordinates**: Convert chromosome positions to genome-wide coordinates using cumulative offsets
2. **GISTIC Processing**: Load amplification/deletion scores and join with genome coordinates
3. **Peak Filtering**: Extract significant peaks (q-value < 0.1) with genomic coordinates
4. **Plot Generation**: Create dual-panel visualization with optimized label positioning
5. **Output**: Generate publication-quality PDF with git-versioned filename

### Design Principles

- **Modular**: Separate functions for data loading, processing, and visualization
- **Documented**: Comprehensive roxygen2 documentation for all functions
- **Reproducible**: Git-based versioning and fixed random seeds
- **Configurable**: Key parameters defined as constants
- **Clean**: Modern tidyverse-based data processing
- **Tested**: Command-line interface with robust error handling

## Output Description

The generated figure contains:

**Panel Layout**: Two-page PDF with amplification and deletion analyses

**Page 1 - Amplification Analysis**:
- Left panel: Peak region labels (top 30 by significance)
- Right panel: Genome-wide amplification significance plot
- Background: Alternating chromosome panels for orientation

**Page 2 - Deletion Analysis**:
- Left panel: Deletion peak labels
- Right panel: Genome-wide deletion significance plot
- Consistent styling and scaling with amplification plots

**Features**:
- Genome-wide x-axis with chromosome boundaries
- Log-scale y-axis for q-values
- Optimized label positioning to avoid overlaps
- Publication-ready formatting and fonts

## Development

### Code Quality
- ✅ **Modular architecture** with specialized functions
- ✅ **Comprehensive documentation** with roxygen2
- ✅ **Consistent code style** following tidyverse conventions
- ✅ **Error handling** with informative messages
- ✅ **Version control** integration with git-based naming
- ✅ **Tested functionality** with command-line interface

### Git Workflow
```bash
# Current branch: doc/info
# Main branches: master, devs
# Output files include git version: fig1_v0.1.3-devs-{commit}.pdf
```

## Troubleshooting

### Common Issues

**1. Missing Dependencies**
```bash
Error: package 'ggrepel' is not installed
```
**Solution**: Install required packages as listed above

**2. File Not Found**
```bash
Error: GISTIC file not found: filename.gistic
```
**Solution**: Check file paths and ensure data files are in correct location

**3. Memory Issues**
```bash
Error: vector memory exhausted
```
**Solution**: Increase R memory limit or use smaller GISTIC files

**4. Plot Generation Errors**
```bash
Error in create_label_plot(): object not found
```
**Solution**: Ensure all R modules are sourced and data is properly loaded

### Data Requirements

- **GISTIC file**: Must contain Type, Chromosome, Start, End, -log10(q-value) columns
- **Peaks file**: Must contain genomic coordinates and q-values
- **Genome reference**: hg19.chrom.sizes must be present for coordinate conversion

## Citation

Generated for PI3K/mTOR manuscript analysis, 2023-05-30.

**Repository**: https://github.com/soccin/PI3K_mTOR_Figure1

## License

Research use - PI3K/mTOR manuscript project.