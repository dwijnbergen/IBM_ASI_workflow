#!/usr/bin/env Rscript
library(data.table)



source("map_identifiers.R")


# infile <- "stringdb_edges"
# outfile <- "stringdb_edges_mapped"

# edges <- fread(infile, sep="\t", colClasses=c("character", "character", "double"))

# mapping <- get_mapping("entrez2string", organism = "Homo sapiens")
# edges <- apply_mapping_edge_list(mapping, edges, column = 1)
# edges <- apply_mapping_edge_list(mapping, edges, column = 2)
# input_identifiers <- union(unlist(edges[,1]), unlist(edges[,2]))

# mapping <- get_mapping("BridgeDB", organism = "Homo sapiens", from = "L", to = "En", identifiers = input_identifiers)
# edges <- apply_mapping_edge_list(mapping, edges, column = 1)
# edges <- apply_mapping_edge_list(mapping, edges, column = 2)

# edges <- remove_duplicate_edges(edges, directed = FALSE)

# fwrite(edges, outfile, quote=F, sep="\t")


#' map STRING DB edge list
#'
#' @param infile The file path with the input edge list
#' 
#' This function maps the STRING DB identifiers
#'
#' @return
#' @export
#'
#' @examples
map_stringdb <- function(infile){
    outfile <- "stringdb_edges_mapped"

    edges <- fread(infile, sep="\t", colClasses=c("character", "character", "double"))
    fwrite(edges, outfile, quote=F, sep="\t")

}

args <- commandArgs(trailingOnly=TRUE)
map_stringdb(args[1])