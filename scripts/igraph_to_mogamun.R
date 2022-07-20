#!/usr/bin/env Rscript

source("prepare_mogamun.R")

map_stringdb <- function(infile){
    #g <- read_graph(infile, format = "graphml")
    g <- readRDS(infile)
    
    mogamun_dir <- "MOGAMUN_input"
    dir.create(mogamun_dir)

    source_layer_mapping = list("STRING" = "db", "miRTarBase" = "db", "cor_mRNA" = "cor", "cor_miRNA" = "cor")
    igraph_to_mogamun(g, mogamun_dir, multiplex = TRUE, source_layer_mapping = source_layer_mapping)
}

args <- commandArgs(trailingOnly=TRUE)
map_stringdb(args[1])