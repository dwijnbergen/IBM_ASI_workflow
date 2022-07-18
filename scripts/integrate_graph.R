#!/usr/bin/env Rscript
library(data.table)
library(igraph)
library(metap)

source("map_identifiers.R")
source("load_omics_data.R")


integrate_graph <- function(stringdb_file, mirtarbase_file, mrna_cor_file, mirna_cor_file, mrna_de_file, miRNA_de_file, variant_burden_file, bridgedb_location, cor_n_max){
    # Load Pvalues and fold changes
    main_pvals <- load_main_pvals(mrna_de_file) # columns are gene, PValue and logFC
    main_pvals$omics <- "mRNA"
    mirna_pvals <- load_mirna_pvals(miRNA_de_file) # columns are gene, PValue and logFC
    mirna_pvals$omics <- "miRNA"
    variant_pvals <- load_variant_pvals(variant_burden_file) # columns are gene, PValue and logFC
    variant_pvals$omics <- "exome"

    # combine main and variant pvals
    gene_variant_mapping <- get_mapping("BridgeDB", organism = "Homo sapiens", from = "H", to = "En", identifiers = unique(variant_pvals$gene), data_location = bridgedb_location)
    variant_pvals_mapped <- variant_pvals
    variant_pvals_mapped$gene <- apply_mapping_vector(gene_variant_mapping, variant_pvals$gene)
    variant_pvals_mapped <- na.omit(variant_pvals_mapped)
    combined_gene_pvals <- merge(main_pvals, variant_pvals_mapped, by = "gene", all = FALSE, suffixes = c(".1", ".2"))
    pvals <- cbind(combined_gene_pvals$PValue.1, combined_gene_pvals$PValue.2)
    new_pvals <- apply(pvals, 1, function(x) sumlog(x)$p)
    combined_gene_pvals$PValue <-  new_pvals
    combined_gene_pvals$main_PValue <- combined_gene_pvals$PValue.1
    combined_gene_pvals$variant_PValue <- combined_gene_pvals$PValue.2
    #combined_gene_pvals$PValue <- combined_gene_pvals$PValue.1
    combined_gene_pvals$omics <- "mRNA + exome"
    combined_gene_pvals$logFC <- combined_gene_pvals$logFC.1

    combined_pvals <- rbind(combined_gene_pvals, mirna_pvals, fill = TRUE)

    # Load edges
    stringdb_edges <- fread(stringdb_file, sep="\t")
    stringdb_edges$source <- "STRING"

    mirtarbase_edges <- fread(mirtarbase_file, sep="\t")
    mirtarbase_edges$source <- "miRTarBase"

    cor_mRNA_edges <- fread(mrna_cor_file, sep="\t", nrows = cor_n_max)
    cor_mRNA_edges$source <- "cor_mRNA"
    colnames(cor_mRNA_edges)[3] <- "Weight"

    cor_miRNA_edges <- fread(mirna_cor_file, sep = "\t", nrows = cor_n_max)
    cor_miRNA_edges$source <- "cor_miRNA"
    colnames(cor_miRNA_edges)[3] <- "Weight"

    combined_edges <- rbind(stringdb_edges, mirtarbase_edges, cor_mRNA_edges, cor_miRNA_edges, use.names = FALSE)

    # Simplify edges
    simplified_edges <- NULL
    for (edge_source in unique(combined_edges$source)){
    source_graph <- graph_from_data_frame(d = combined_edges[combined_edges$source == edge_source], directed = FALSE)
    print(paste("Removing", sum(which_multiple(source_graph)), "duplicate edges from", edge_source))
    source_graph <- simplify(source_graph, edge.attr.comb = "random")
    simplified_edges <- rbind(simplified_edges, as_data_frame(source_graph))
    }
    colnames(simplified_edges) <- colnames(combined_edges)

    # Make igraph graph
    g <- graph_from_data_frame(d = simplified_edges, directed = FALSE)

    # Keep only largest component
    comps <- components(g)
    largest_comp <- which.max(comps[["csize"]])
    members <- which(comps$membership == largest_comp)
    g <- induced_subgraph(g, members)

    # Add names to graph
    mapping1 <- get_mapping("BridgeDB", organism = "Homo sapiens", from = "En", to = "H", identifiers = V(g)$name, data_location = bridgedb_location)
    mapping2 <- get_mapping("miRBaseConverter", from = "Accession", to = "Name", identifiers = V(g)$name)
    colnames(mapping1) <- c("From", "To")
    colnames(mapping2) <- c("From", "To")
    mapping <- rbind(mapping1, mapping2)
    mapping <- mapping[!is.na(mapping$To), ]

    V(g)$label <- apply_mapping_vector(mapping, V(g)$name)

    # Set attributes (mainly pvalues) to graph
    filtered_pvals <- combined_pvals[unlist(combined_pvals$gene) %in% V(g)$name, ]
    V(g)[unlist(filtered_pvals$gene)]$pvalue <- unlist(filtered_pvals$PValue)
    V(g)$pvalue[is.na(V(g)$pvalue)] <- 1
    V(g)[unlist(filtered_pvals$gene)]$main_pvalue <- unlist(filtered_pvals$main_PValue)
    V(g)[unlist(filtered_pvals$gene)]$variant_pvalue <- unlist(filtered_pvals$variant_PValue)
    V(g)[unlist(filtered_pvals$gene)]$logFC <- unlist(filtered_pvals$logFC)
    V(g)$logFC[is.na(V(g)$logFC)] <- 0
    V(g)[unlist(filtered_pvals$gene)]$omics <- unlist(filtered_pvals$omics)
    g <- delete_vertices(g, is.na(V(g)$omics))

    # Add multiple testing corrected p-values for interpretation
    for (omic in unique(V(g)$omics)){
        V(g)[V(g)$omics == omic]$padj <- p.adjust(V(g)[V(g)$omics == omic]$pvalue, method = "BH")
        V(g)[V(g)$omics == omic]$main_pvalue_adj <- p.adjust(V(g)[V(g)$omics == omic]$main_pvalue, method = "BH")
        V(g)[V(g)$omics == omic]$variant_pvalue_adj <- p.adjust(V(g)[V(g)$omics == omic]$variant_pvalue, method = "BH")
        if (omic == "miRNA") {
            V(g)[V(g)$omics == omic]$main_pvalue_adj <- p.adjust(V(g)[V(g)$omics == omic]$pvalue, method = "BH")
        }
    }

    write_graph(g, "full_graph.graphml", format = "graphml")
}

args <- commandArgs(trailingOnly=TRUE)
integrate_graph(args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], as.integer(args[9]))