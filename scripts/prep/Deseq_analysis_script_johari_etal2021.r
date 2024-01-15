# Pacman for efficient package management
if (!require(pacman)) install.packages("pacman")
pacman::p_load(DESeq2, RColorBrewer, gridExtra,
              tidyverse, ggbeeswarm, ashr)

# Define functions
# Function for reading in the data
read_data <- function(file_path) {
    read.table(file_path, header = TRUE, row.names = 1)
}

# Function for DESeq2 analysis
run_deseq2 <- function(count_data, condition, design_formula) {
    col_data <- data.frame(row.names = colnames(count_data), condition)
    dds <- DESeqDataSetFromMatrix(countData = count_data, colData = col_data, design = design_formula)
    dds <- estimateSizeFactors(dds)
    return(dds)
}

# Function for PCA plotting
plot_pca <- function(vsd_data, cohorts, intgroup, colors) {
    subset_data <- vsd_data[, vsd_data$Cohort %in% cohorts]
    pca_data <- plotPCA(subset_data, intgroup = intgroup, returnData = TRUE)
    percentVar <- 100 * round(attr(pca_data, "percentVar"), 2)
    makeLab <- function(x, pc) paste0("PC", pc, ": ", x, "% variance")
    
    ggplot(pca_data, aes_string(x = "PC1", y = "PC2", color = "Cohort")) +
        geom_point(size = 3) +
        xlab(makeLab(percentVar[1], 1)) + 
        ylab(makeLab(percentVar[2], 2)) +
        scale_colour_manual(values = colors)
}

# Function for DESeq2 results
run_deseq2_results <- function(dds, contrast) {
    # Calculate results
    res <- results(dds, contrast = contrast)

    # Shrinkage calculation
    res_shrink <- lfcShrink(dds, type = 'ashr', contrast = contrast, res = res)

    # Order by padj
    res_ordered <- res_shrink[order(res_shrink$padj),]

    return(list(results = res, shrink = res_shrink, ordered = res_ordered))
}

# Function for writing and merging files
merge_and_write <- function(res, dds, file_name) {
    merged_res <- merge(
        as.data.frame(res),
        as.data.frame(counts(dds, normalized = TRUE)),
        by = "row.names", sort = FALSE
    )
    names(merged_res)[1] <- "Gene"
    write.csv(merged_res, file = file_name)
    return(merged_res)  # Optionally return the merged data for verification
}

# Function for subsetting and writing the files
subset_and_write <- function(res_data, file_name, logFC_threshold, padj_threshold, direction = "up") {
  if (direction == "down") {
    subset_res <- subset(
      res_data,
      res_data$log2FoldChange <= -logFC_threshold & res_data$padj < padj_threshold
    )
  } else {
    subset_res <- subset(
      res_data,
      res_data$log2FoldChange >= logFC_threshold & res_data$padj < padj_threshold
    )
  }
  write.csv(subset_res, file = file_name)
}

# Start analysis
# Read data
countdata_main <- read_data("39_PE_samples_fragmentcounts_noMulti_noOverlap_updated.txt")
countdata_lnc <- read_data("lncRNA_39_PE_samples_fragmentcounts_noMulti_noOverlap_updated.txt")
condition <- read.csv("Sample_metadata_final.csv", header = TRUE, sep = ",")

# Run DESeq2 analysis
dds_main <- run_deseq2(countdata_main, condition, ~ Cohort)
dds_lnc <- run_deseq2(countdata_lnc, condition, ~ Cohort)

# Variant stabilizing transformation for PCA
vsd_main <- varianceStabilizingTransformation(dds_main, blind = FALSE)
vsd_lnc <- varianceStabilizingTransformation(dds_lnc, blind = FALSE)


# Set colour mapping
cols0 <- c("IBM" = "Blue", "group_TMD" = "Green", "group_Amputee" = "#D55E00")
cols1 <- c("IBM" = "Blue", "group_Amputee" = "#D55E00")
cols2 <- c("IBM" = "Blue", "group_TMD" = "Green")

# Pairwise comparison PCA
p1 <- plot_pca(vsd_main, c("IBM", "group_Amputee"), c("Cohort", "Batch"), cols1)
p2 <- plot_pca(vsd_main, c("IBM", "group_TMD"), c("Cohort"), cols2)

# DESeq2 analysis
dds_main <- DESeq(dds_main)
dds_lnc <- DESeq(dds_lnc)

# Calculate results, compare contrasts, estimate shrinkage
contrasts_lists <- list(
    IBM_AMP = c("Cohort", "IBM", "group_Amputee"),
    IBM_TMD = c("Cohort", "IBM", "group_TMD"),
    TMD_AMP = c("Cohort", "group_TMD", "group_Amputee")
)

results_main <- lapply(contrasts_lists, function(contrast) run_deseq2_results(dds_main, contrast))
results_lnc <- lapply(contrasts_lists, function(contrast) run_deseq2_results(dds_lnc, contrast))

# For main dataset
resSort.lfcShrink.IBM_AMP_main <- results_main$IBM_AMP$ordered
resSort.lfcShrink.IBM_TMD_main <- results_main$IBM_TMD$ordered
resSort.lfcShrink.TMD_AMP_main <- results_main$TMD_AMP$ordered

# Merge, write, and save merged datasets
merged_resSort.lfcShrink.IBM_AMP_main <- merge_and_write(resSort.lfcShrink.IBM_AMP_main, dds_main, "resSort.lfcShrink.IBM_AMP_main.updated.csv")
merged_resSort.lfcShrink.TMD_AMP_main <- merge_and_write(resSort.lfcShrink.TMD_AMP_main, dds_main, "resSort.lfcShrink.TMD_AMP_main.updated.csv")
merged_resSort.lfcShrink.IBM_TMD_main <- merge_and_write(resSort.lfcShrink.IBM_TMD_main, dds_main, "resSort.lfcShrink.IBM_TMD_main.updated.csv")

# For lncRNA dataset
resSort.lfcShrink.IBM_AMP_lnc <- results_lnc$IBM_AMP$ordered
resSort.lfcShrink.IBM_TMD_lnc <- results_lnc$IBM_TMD$ordered
resSort.lfcShrink.TMD_AMP_lnc <- results_lnc$TMD_AMP$ordered

# Merge, write, and save merged datasets
merged_resSort.lfcShrink.IBM_AMP_lnc <- merge_and_write(resSort.lfcShrink.IBM_AMP_lnc, dds_lnc, "resSort.lfcShrink.IBM_AMP_lnc.updated.csv")
merged_resSort.lfcShrink.TMD_AMP_lnc <- merge_and_write(resSort.lfcShrink.TMD_AMP_lnc, dds_lnc, "resSort.lfcShrink.TMD_AMP_lnc.updated.csv")
merged_resSort.lfcShrink.IBM_TMD_lnc <- merge_and_write(resSort.lfcShrink.IBM_TMD_lnc, dds_lnc, "resSort.lfcShrink.IBM_TMD_lnc.updated.csv")


# Main dataset
# upregulated genes
subset_and_write(merged_resSort.lfcShrink.IBM_AMP_main, "resSort_main_up.lfcShrink.IBM_AMP.csv", 1.5, 0.01, "up")
subset_and_write(merged_resSort.lfcShrink.TMD_AMP_main, "resSort_main_up.lfcShrink.TMD_AMP.csv", 1.5, 0.01, "up")
subset_and_write(merged_resSort.lfcShrink.IBM_TMD_main, "resSort_main_up.lfcShrink.IBM_TMD.csv", 1.5, 0.01, "up")

# downreglated genes
subset_and_write(merged_resSort.lfcShrink.IBM_AMP_main, "resSort_main_down.lfcShrink.IBM_AMP.csv", 1.5, 0.01, "down")
subset_and_write(merged_resSort.lfcShrink.TMD_AMP_main, "resSort_main_down.lfcShrink.TMD_AMP.csv", 1.5, 0.01, "down")
subset_and_write(merged_resSort.lfcShrink.IBM_TMD_main, "resSort_main_down.lfcShrink.IBM_TMD.csv", 1.5, 0.01, "down")

# LncRNA dataset
# upreglated genes
subset_and_write(merged_resSort.lfcShrink.IBM_AMP_lnc, "resSort_lnc_up.lfcShrink.IBM_AMP.csv", 1.5, 0.01, "up")
subset_and_write(merged_resSort.lfcShrink.TMD_AMP_lnc, "resSort_lnc_up.lfcShrink.TMD_AMP.csv", 1.5, 0.01, "up")
subset_and_write(merged_resSort.lfcShrink.IBM_TMD_lnc, "resSort_lnc_up.lfcShrink.IBM_TMD.csv", 1.5, 0.01, "up")

# downregulated genes
subset_and_write(merged_resSort.lfcShrink.IBM_AMP_lnc, "resSort_lnc_down.lfcShrink.IBM_AMP.csv", 1.5, 0.01, "down")
subset_and_write(merged_resSort.lfcShrink.TMD_AMP_lnc, "resSort_lnc_down.lfcShrink.TMD_AMP.csv", 1.5, 0.01, "down")
subset_and_write(merged_resSort.lfcShrink.IBM_TMD_lnc, "resSort_lnc_down.lfcShrink.IBM_TMD.csv", 1.5, 0.01, "down")