library(Rcpp)
library(stringr)

# Load normalized count data
main <- read.csv("data/dds_main_counts.txt", sep = " ")
rownames(main) <- as.character(lapply(rownames(main), function(x) {str_extract(x, "ENSG[0-9]+")}))
mirna <- read.csv("data/dds_mirna_counts.txt", sep = " ")
gene_lookuptable <- read.table("data/gene_lookuptable.tsv", sep = "\t", header = TRUE)

# Use only protein coding mRNA
protein_coding_genes <- gene_lookuptable$ensembl_gene_id[gene_lookuptable$gene_biotype == "protein_coding"]
main <- main[rownames(main) %in% protein_coding_genes,]

# Extract only shared samples
shared_samples <- intersect(colnames(main), colnames(mirna))
shared_main <- main[, shared_samples]
shared_mirna <- mirna[, shared_samples]
combined <- rbind(main[,shared_samples], mirna[,shared_samples])

# Leave out genes with 0 counts in > 1/2 of the samples
shared_main_filtered <- shared_main[rowMeans(shared_main > 0) > 0.5, ]
shared_mirna_filtered <- shared_mirna[rowMeans(shared_mirna > 0) > 0.5, ]
combined_filtered <- combined[rowMeans(combined > 0) > 0.5, ]

# Histograms
test <- shared_main_filtered[sample(nrow(shared_main_filtered), 1000),]
test2 <- shared_mirna_filtered[sample(nrow(shared_mirna_filtered), 1000),]
correlation_matrix <- cor(t(test), method="pearson")
hist(c(correlation_matrix), xlab = "Pearson Correlation")
correlation_matrix <- cor(t(test), t(test2), method="pearson")
hist(c(correlation_matrix),xlab = "Pearson Correlation")

# Load cpp script and test
# test <- combined_filtered
# test <- as.matrix(test)
sourceCpp("cor_edge.cpp")

# Get edges
a <- cor_edge_mRNA(as.matrix(shared_main_filtered), 0.7)
b <- cor_edge_mRNA_miRNA(as.matrix(shared_main_filtered), as.matrix(shared_mirna_filtered), -0.5)

a$in_v <- rownames(shared_main_filtered)[a$in_v]
a$out_v <- rownames(shared_main_filtered)[a$out_v]

b$in_v <- rownames(shared_main_filtered)[b$in_v] # Change one of these!
b$out_v <- rownames(shared_mirna_filtered)[b$out_v] # Change one of these!

# Write to files
write.table(as.data.frame(a), "data/mRNA-cor_edges_bicor", sep = "\t", row.names = FALSE)
write.table(as.data.frame(b), "data/mRNA-miRNA_cor_edges_bicor", sep = "\t", row.names = FALSE)