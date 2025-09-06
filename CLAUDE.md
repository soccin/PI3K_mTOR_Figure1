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

## Style Guidelines

**IMPORTANT: NO EMOJI USAGE**
- Do NOT use emoji in commit messages, code comments, documentation, or any files
- Keep all text professional and emoji-free
- This applies to all development work in this repository

**WHITESPACE MANAGEMENT**
- Remove trailing unnecessary whitespace at the end of all lines
- Keep codebase clean to avoid version control noise
- Apply to all R scripts, documentation, and text files
- CAUTION: Use precise whitespace removal to avoid truncating legitimate text

## R Code Quality Guidelines

### Core Philosophy: Clarity Over Compliance
- **Human comprehension first**: Code should tell a clear story to humans
- **Style serves clarity**: Formatting rules help readability, not hinder it
- **Simple over sophisticated**: Use the simplest construct that accomplishes the goal

### 1. Prefer Clear Logic Flow
```r
# GOOD: Linear, obvious progression
data %>%
  read_tsv() %>%
  clean_names() %>%
  filter(condition) %>%
  mutate(new_col = transformation) %>%
  select(final_columns)

# AVOID: Complex nested operations that require mental parsing
data %>% mutate(coords = map(.[[4]], complex_parser))
```

### 2. Use Meaningful Names Throughout
- Function names should describe what they do: `parse_peak_strings()` not `extract_coords()`
- Variable names should be immediately clear: `lesions_file` not `input_path`
- Avoid cryptic references like `.[[4]]` - use named columns

### 3. Keep Functions Focused and Simple
- One clear purpose per function
- Minimal abstraction unless there's real benefit
- Prefer obvious implementations over "clever" ones

### 4. Minimize Cognitive Load
- Avoid introducing multiple new concepts simultaneously
- Don't add error handling/validation unless actually needed
- Keep the main logic visible, not buried in abstractions
- Progressive complexity: start simple, add only when necessary

### 5. Documentation Should Clarify, Not Obscure
- Use standard roxygen2 documentation for all functions (@param, @return)
- Brief comments for complex logic only
- Don't document obvious operations
- Function documentation should be concise and purpose-focused

### 6. Tidyverse Usage Guidelines
- Use `|>` (native pipe) over `%>%` (magrittr) for R compatibility unless the specific code involved needs the advanced functionality of `%>%`. For example:
  ```r
  y = x %>% split(.$group)
  ```
  does not work with `|>` so it needs to stay with `%>%`. It is ok to mix the two but only if needed.
- Prefer standard dplyr verbs over complex functional programming constructs
- Use `select()`, `filter()`, `mutate()` over base R equivalents for consistency
- Avoid overly functional approaches (excessive `map()`, `purrr`) when simple solutions exist

### 7. Error Handling Philosophy
- Add error handling only when failure is likely or consequences are severe
- Use simple checks rather than comprehensive validation for internal functions
- Fail fast with clear messages rather than defensive programming everywhere

### 8. Code Organization
- Place utility functions near where they're used
- Keep related operations together
- Use clear section breaks only when they aid comprehension
- Avoid excessive abstraction layers

### Anti-Patterns to Avoid
- Over-documentation that obscures simple logic
- Complex functional programming when procedural is clearer
- Premature abstraction and generalization
- Defensive programming for every edge case
- "Clever" code that requires mental decoding

### The Test: Can a collaborator understand this code in 30 seconds?
If not, it's probably too complex regardless of how "correct" the style is.