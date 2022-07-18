#!/usr/bin/env Rscript
library(data.table)

source("map_identifiers.R")


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
map_stringdb <- function(infile, entrez2gene_location, bridgedb_location){
    outfile <- "stringdb_edges_mapped"

    # Read original edges
    edges <- fread(infile, sep="\t", colClasses=c("character", "character", "double"))

    # Map with STRING mapping
    mapping <- get_mapping("entrez2string",
        organism = "Homo sapiens", data_location = entrez2gene_location)
    edges <- apply_mapping_edge_list(mapping, edges, column = 1)
    edges <- apply_mapping_edge_list(mapping, edges, column = 2)

    # Map with BridgeDB
    input_identifiers <- union(unlist(edges[,1]), unlist(edges[,2]))
    mapping <- get_mapping("BridgeDB", organism = "Homo sapiens",
        from = "L", to = "En", identifiers = input_identifiers,
        data_location = bridgedb_location)
    edges <- apply_mapping_edge_list(mapping, edges, column = 1)
    edges <- apply_mapping_edge_list(mapping, edges, column = 2)

    # Remove duplicate edges
    edges <- remove_duplicate_edges(edges, directed = FALSE)

    # Write to output
    fwrite(edges, outfile, quote=F, sep="\t")
}

args <- commandArgs(trailingOnly=TRUE)
map_stringdb(args[1], args[2], args[3])