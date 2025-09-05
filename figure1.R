require(tidyverse)
require(ggrepel)
require(patchwork)

source("R/load_gistic_data.R")

remove_x_axis <- function(plot) {
  plot + theme(
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.title.x = element_blank()
  )
}

hg19=load_genome_info()
hg19.gistic=hg19 %>% filter(chromosome %in% 1:22)
genomeRange=rev(range(hg19.gistic$g_offset)+c(0,hg19.gistic$len[22]))

gg=load_gistic_data("iClust_1_scores.gistic")

g1=gg$Amp

g1=g1 %>% arrange(desc(log10_q_value)) %>% mutate(Label=ifelse(row_number()<15,sprintf("P%02d",row_number()),"")) %>% arrange(gPos)


l1=read_csv("iClust1Peaks.csv") %>% select(chromosome,pos,Label=descriptor,everything()) %>% mutate(chromosome=as.character(chromosome)) %>% left_join(hg19,by="chromosome") %>% mutate(gPos=pos+g_offset,Y=1) %>% select(gPos,Y,Label,q_values) %>% arrange(gPos)
l1=l1 %>% filter(q_values<0.1)

genomeRange=rev(range(c(l1$gPos,g1$gPos)))

p1=ggplot(g1,aes(gPos,10^(log10_q_value))) + geom_step(color="darkred") + theme_light() + scale_y_log10(expand=c(0,0,0.01,0)) + coord_flip(clip="off") + scale_x_reverse(limits=genomeRange,expand=c(0,0,0,0))
p1a=p1 + theme(axis.text.y=element_blank(),axis.ticks=element_blank(),axis.title=element_blank(), plot.margin=margin(10,10,0,0,"pt"),panel.spacing = unit(0, "pt"))

#p2=l1 %>% ggplot(aes(gPos,Y,label=Label)) + theme_void() + geom_label_repel(ylim=c(.5,.7),max.overlaps=15,min.segment.length=0,segment.curvature = -1e-20,direction="y",force=0.1,force_pull=5,max.iter=10000,max.time=2) + coord_flip(clip="off") + scale_x_reverse(limits=genomeRange) + scale_y_continuous(limits=c(0,1),expand=c(0,0)) + theme(plot.margin=margin(0,0,0,-10,"pt"),panel.spacing = unit(0, "pt"),panel.border = element_blank())
#p2=l1 %>% ggplot(aes(gPos,Y,label=Label)) + theme_void() + geom_text_repel(ylim=c(0,.95),force=5,min.segment.length=0,segment.curvature = -1e-20) + coord_flip(clip="off") + scale_x_reverse(limits=genomeRange) + scale_y_continuous(limits=c(0,1),expand=c(0,0)) + theme(plot.margin=margin(0,0,0,-10,"pt"),panel.spacing = unit(0, "pt"),panel.border = element_blank())

#(p2 | p1a) & theme(plot.margin = margin(0, 0, 0, 0))

p2 <- l1 %>% arrange(gPos) %>%
  ggplot(aes(gPos, Y, label=Label)) +
  theme_void() +
  geom_text_repel(
    max.overlaps = Inf,
    min.segment.length = 0,
    segment.curvature = -1e-20,
    max.iter = 10000,          # High iteration count
    max.time = 3,              # More time to optimize
    force = 1.2,
    seed = 42,                 # Reproducible results
    segment.color = "black",
    segment.size = 0.3,
    ylim=c(0,.95)
  ) +
  coord_flip(clip="off") +
  scale_x_reverse(limits=genomeRange,expand=c(0,0,0,0)) +
  scale_y_continuous(limits=c(0, 1), expand=c(0,0)) +
  theme(plot.margin = margin(10, 0, 0, 0, "pt"))

pAmp=(p2 | p1a )
pdf(file="test02.pdf",height=11,width=8.5)
print(pAmp)
dev.off()