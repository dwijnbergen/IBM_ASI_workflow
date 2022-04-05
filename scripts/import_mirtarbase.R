#' Import mirtarbase edge list
#'
#' @param outfile The file path destination for the edge list
#'
#' @return
#' @export
#'
#' @examples
import_mirtarbase <- function(infile, outfile, n_max = Inf){
    #library(readxl)
    library(openxlsx)
    library(data.table)

    # Format edges
    if (n_max == Inf){
        edges <- read.xlsx(infile, sheet = 1)
    } else {
        edges <- read.xlsx(infile, sheet = 1, rows = 1:n_max)
    }
    # Extract columns with MiRTarBase IDs and Target Gene Entrez Gene IDs
    edges <- edges[c(2,5)]
    # Add column with edge weights (all 1 for now)
    edges$Weight = 1
    # Write to file
    fwrite(edges, outfile, quote=F, sep="\t")
}

args = commandArgs(trailingOnly=TRUE)
import_mirtarbase(args[1], args[2])
