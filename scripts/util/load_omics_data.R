library(data.table)
library(stringr)

load_main_pvals <- function(infile){
  pvals <- fread(infile, sep=" ")
  pvals <- na.omit(pvals)
  pvals$V1 <- as.character(lapply(pvals$V1, function(x) {str_extract(x, "ENSG[0-9]+")}))
  pvals <- pvals[, c("V1", "pvalue", "log2FoldChange")]
  colnames(pvals) <- c("gene", "PValue", "logFC")

  return(pvals)
}

load_mirna_pvals <- function(infile){
  pvals <- fread(infile, sep=" ")
  pvals <- na.omit(pvals)
  pvals <- pvals[, c("V1", "pvalue", "log2FoldChange")]
  colnames(pvals) <- c("gene", "PValue", "logFC")

  return(pvals)
}

load_variant_pvals <- function(infile){
  pvals <- fread(infile, sep = "\t")
  pvals <- na.omit(pvals)
  pvals <- pvals[, c("Gene", "Pvalue")]
  pvals$logFC <- 0
  colnames(pvals) <- c("gene", "PValue", "logFC")

  return(pvals)
}