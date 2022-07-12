#!/usr/bin/env Rscript

#' Import STRING DB edge list
#'
#' @param outfile The file path destination for the edge list
#' 
#' This function downloads protein links from STRING DB, extracts the archive, and prepares the file for input
#'
#' @return
#' @export
#'
#' @examples
import_stringdb <- function(infile, n_max = Inf, min_weight = 1){
  # Change delimited to tab, select identifiers and experimental score, remove prefix from identifiers and change column names
  #  | sed "s/9606\\.//g" can be used to remove NCBI taxid prefix
  awkcode <- paste0("'{if($7 >= ",min_weight ,"){print($0)}}'")
  outfile <- "stringdb_edges"

  if (n_max == Inf){
    system(paste('zcat',infile ,'| tr " " "\t" | awk', awkcode, '| cut -f 1,2,7 | sed "1 s/protein/Ensembl ID /g" | sed "1 s/experimental/Weight/" >', outfile))
  } else {
    system(paste('zcat',infile ,'| tr " " "\t" | awk', awkcode, '| cut -f 1,2,7 | sed "1 s/protein/Ensembl ID /g" | sed "1 s/experimental/Weight/" | head -n', n_max, '>', outfile))
  }
}

args <- commandArgs(trailingOnly=TRUE)
import_stringdb(args[1], n_max = args[2], min_weight = args[3])