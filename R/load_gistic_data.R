suppressPackageStartupMessages({
  require(dplyr)
  require(magrittr)
})
source(file.path(get_script_dir(),"R/load_genome_info.R"))

load_gistic_data<-function(gfile) {
  hg19=load_genome_info()
  readr::read_tsv(gfile,show_col_types=F,progress=F) |>
    janitor::clean_names() |>
    mutate(chromosome=as.character(chromosome)) |>
    left_join(hg19,by="chromosome") |>
    mutate(gPos=start+g_offset) |>
    select(type,chromosome,gPos,log10_q_value) %>%
    split(.$type)
}

