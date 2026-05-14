#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
fc_file <- args[1]

cat("Reading the featureCounts output...\n")
fc_data <- read.table(fc_file, header = TRUE, row.names = 1, comment.char = "#", stringsAsFactors = FALSE)

gene_lengths <- fc_data$Length
counts <- fc_data[, 6:ncol(fc_data)]

colnames(counts) <- gsub("\\.Aligned\\.sortedByCoord\\.out\\.bam$", "", colnames(counts))
colnames(counts) <- gsub("\\.bam$", "", colnames(counts))
colnames(counts) <- sub("^X", "", colnames(counts))

# 3. Calcolo dei TPM = Transcripts Per Million
cat("Calculating TPMs...\n")
rpk <- counts / (gene_lengths / 1000)
tpm <- t(t(rpk) / (colSums(rpk) / 1e6))

write.table(as.data.frame(tpm), file="tpm_matrix.txt", sep="\t", quote=FALSE, col.names=NA)
cat("TPM matrix generated succesfully \n")
