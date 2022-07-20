library(data.table)
library(stringr)
library(MOGAMUN)
library(igraph)

prepare_mogamun_pvals <- function(mogamun_dir, pval_data){
  dir.create(mogamun_dir, showWarnings = FALSE)

  pvals <- pval_data[[1]]
  if (length(pval_data) > 1) {
    for (i in 2:length(pval_data)){
      pvals <- rbind(pvals, pval_data[[i]])
    }
  }

  fwrite(pvals, file.path(mogamun_dir, "pvals.csv"), quote=F, sep=",")
}

prepare_mogamun_nodescores <- function(mogamun_dir, pval_data){
  dir.create(mogamun_dir, showWarnings = FALSE)

  nodescore_data <- list()
  for (i in 1:length(pval_data)) {
    nodescores <- as.numeric(MOGAMUN:::GetNodesScoresOfListOfGenes(pval_data[[i]], as.character(pval_data[[i]]$gene), "PValue"))
    nodescore_data[[i]] <- data.frame("gene" = as.character(pval_data[[i]]$gene), "nodescore" = nodescores)
  }
  
  nodescores <- nodescore_data[[1]]
  if (length(nodescore_data) > 1) {
    for (i in 2:length(nodescore_data)){
      nodescores <- rbind(nodescores, nodescore_data[[i]])
    }
  }

  fwrite(nodescores, file = file.path(mogamun_dir, "NodeScores.csv"), quote=T, sep=",")
}

prepare_mogamun_network <- function(mogamun_dir, edge_file, network_name) {
  dir.create(mogamun_dir, showWarnings = FALSE)
  dir.create(file.path(mogamun_dir, "networks"), showWarnings = FALSE)
  
  edges <- fread(edge_file, sep="\t")
  edges <- edges[,c(1,2)]
  fwrite(edges, file.path(mogamun_dir, "networks", network_name), quote=F, sep="\t", col.names = FALSE)
}

igraph_to_mogamun <- function(g, mogamun_dir, multiplex = FALSE, source_layer_mapping = list()) {
  dir.create(mogamun_dir, showWarnings = FALSE)
  
  # pvals
  tmp <- vertex_attr(g)
  pvals <- data.frame("gene" = tmp$name, PValue = tmp$pvalue, "logFC" = tmp$logFC, "omics" = tmp$omics)
  fwrite(pvals, file.path(mogamun_dir, "pvals.csv"), quote=F, sep=",")
  
  # Node scores
  pvals$omics <- "ignore"
  pval_data <- split(pvals, with(pvals, omics))
  prepare_mogamun_nodescores(mogamun_dir, pval_data)
  
  # Edges
  dir.create(file.path(mogamun_dir, "networks"), showWarnings = FALSE)

  if (length(source_layer_mapping) > 0){
    layer <- as.vector(unlist(source_layer_mapping[E(g)$source]))
    if (length(layer) != length(E(g)$source)){
      stop("Incorrect edge source data or incorrect source layer mapping")
    }
    E(g)$source <- layer
  }
  
  if (multiplex) {
    sources <- unique(E(g)$source)
    for (i in 1:length(sources)){
      edge_ids <- which(E(g)$source == sources[i])
      g_layer <- subgraph.edges(g, edge_ids)
      layer_name <- paste0(i, "_", sources[i])
      fwrite(as.data.table(as_edgelist(g_layer)),
             file.path(mogamun_dir, "networks", layer_name),
             quote=F, sep="\t", col.names = FALSE)
    }
  } else {
    fwrite(as.data.table(as_edgelist(g)), file.path(mogamun_dir, "networks", "1_all"), quote=F, sep="\t", col.names = FALSE)
  }
}