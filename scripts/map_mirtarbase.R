#!/usr/bin/env Rscript
library(data.table)

source("map_identifiers.R")


#' map miRTarBase edge list
#'
#' @param infile The file path with the input edge list
#' 
#' This function maps the miRTarBase identifiers
#'
#' @return
#' @export
#'
#' @examples
map_mirtarbase <- function(infile, bridgedb_location){
    outfile <- "mirtarbase_edges_mapped"


    # Read original edges
    edges <- fread(infile, sep="\t", colClasses=c("character", "character", "double"))

    # Map miRNA identifiers with miRBaseConverter
    input_identifiers <- unique(unlist(edges[,1]))
    mapping <- get_mapping("miRBaseConverter", from = "Name",
        to = "Accession", identifiers = input_identifiers)
    edges <- apply_mapping_edge_list(mapping, edges, column = 1)

    # Map gene identifiers with BridgeDB
    input_identifiers <- unique(unlist(edges[,2]))
    mapping <- get_mapping("BridgeDB", organism = "Homo sapiens",
        from = "L", to = "En", identifiers = input_identifiers,
        data_location = bridgedb_location)
    edges <- apply_mapping_edge_list(mapping, edges, column = 2)

    # Remove duplicate edges
    edges <- remove_duplicate_edges(edges, directed = FALSE)

    # Write to output
    fwrite(edges, outfile, quote=F, sep="\t")
}

args <- commandArgs(trailingOnly=TRUE)
map_mirtarbase(args[1], args[2])