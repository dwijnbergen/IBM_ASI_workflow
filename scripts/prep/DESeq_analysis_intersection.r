library(DESeq2)
library(rafalib) #BiocManager::install("rafalib")
library(ggplot2) #BiocManager::install("ggplot2")
library(pheatmap) #BiocManager::install("pheatmap")
library(RColorBrewer) #BiocManager::install("RColorBrewer")
library(dplyr) #BiocManager::install("dplyr")
library(plotly) #BiocManager::install("plotly")
library(org.Hs.eg.db) #BiocManager::install("org.Hs.eg.db")
library(devtools) #BiocManager::install("devtools")
library(EnsDb.Hsapiens.v86) #BiocManager::install("EnsDb.Hsapiens.v86")
library(gridExtra) #BiocManager::install("gridExtra")
library(EnhancedVolcano) #BiocManager::install("EnhancedVolcano")
library(survminer) #BiocManager::install("survminer")
library(biomaRt) #BiocManager::install("biomaRt")
library(tidyverse) #BiocManager::install("tidyverse")
library(genefilter) #BiocManager::install("genefilter")
library(tidyr) #BiocManager::install("tidyr")
library(VennDiagram) #BiocManager::install("VennDiagram")
library(ggbeeswarm)


#INPUT data
countdata_main <- read.table(
    "ComprehensiveRNA_39_PE_samples_fragmentcounts_noMulti_noOverlap_updated.txt", 
    header=TRUE, row.names=1
    )
countdata_mirna <- read.table(
    "miRNA_raw_counts.txt", 
    header=TRUE, row.names=1
    )
condition_main <- read.csv(
    "sample_metadata_final.csv",
    header=TRUE, row.names=1, sep=","
    )
condition_mirna<- read.csv(
    "Sample_metadata_miRNA_updated.csv",
    header=TRUE, row.names=1,sep=","
    )

##Making dds element
(coldata_main <- data.frame(
    row.names=colnames(countdata_main), condition_main))
(coldata_mirna <- data.frame(
    row.names=colnames(countdata_mirna), condition_mirna))


##Feed this info into the dds matrix element
dds_main <- DESeqDataSetFromMatrix(
    countData = countdata_main, 
    colData = coldata_main, 
    design = ~ Cohort
    )
dds_mirna <- DESeqDataSetFromMatrix(
    countData = countdata_mirna, 
    colData = coldata_mirna, 
    design = ~ Cohort
    )

#print normalized counts for the upload, used also for correleation based edges
dds_main_counts<-counts(dds_main, normalized=TRUE)
write.table(dds_main_counts, file="dds_main_counts.txt")
dds_mirna_counts<-counts(dds_mirna, normalized=TRUE)
write.table(dds_mirna_counts, file="dds_mirna_counts.txt")

#Use only overlapping samples
overlapping_samples <- intersect(colnames(dds_main), colnames(dds_mirna))
dds_main <- dds_main[, overlapping_samples]
dds_mirna <- dds_mirna[, overlapping_samples]

dds_main <- estimateSizeFactors(dds_main)
dds_mirna <- estimateSizeFactors(dds_mirna)

#Variant stabilizing transformation of the data
vsd_main <- varianceStabilizingTransformation(dds_main, blind=FALSE)
head(assay(vsd_main))
hist(assay(vsd_main))
vsd_mirna <- varianceStabilizingTransformation(dds_mirna, blind=FALSE)
head(assay(vsd_mirna))
hist(assay(vsd_mirna))

dds_main <- DESeq(dds_main)
dds_mirna <- DESeq(dds_mirna)

res.sIBM_AMP_main <- results(dds_main, contrast=c("Cohort", "IBM", "Control_Amputee"))
res.sIBM_AMP_mirna <- results(dds_mirna, contrast=c("Cohort", "sIBM", "Control_Amputee"))

res.sIBM_AMP_main_sorted <- res.sIBM_AMP_main[order(res.sIBM_AMP_main$padj),]
res.sIBM_AMP_mirna_sorted <- res.sIBM_AMP_mirna[order(res.sIBM_AMP_mirna$padj),]

write.table(res.sIBM_AMP_main_sorted, file="res_sIBM_AMP_main_updated.txt")
write.table(res.sIBM_AMP_mirna_sorted, file="res_sIBM_AMP_main_updated.txt")