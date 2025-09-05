suppressPackageStartupMessages(require(dplyr))
load_genome_info<-function() {
  hg19Chroms=c(1:22,"X","Y","M")
  hg19=readr::read_tsv(
      "hg19.chrom.sizes",
      col_names=c("chromosome","len"),
      show_col_types=F,
      progress=F
    ) |>
    mutate(chromosome=gsub("^chr","",chromosome)) |>
    mutate(chr=factor(chromosome,levels=hg19Chroms)) |>
    arrange(chr) |>
    filter(!is.na(chr))
  hg19$g_offset=c(0,cumsum(hg19$len)) |> head(-1)
  hg19 |> select(chromosome,g_offset,len)
}
