#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
counts_file <- args [1]
metadata_file <-args [2]
user_design <-args[3]

library(DESeq2)

counts <- read.table(counts_file, header = TRUE, row.names = 1, stringsAsFactors = FALSE)
meta <- read.csv(metadata_file, row.names = 1, stringsAsFactors = TRUE)

counts <- counts[, 6:ncol(counts)]

colnames(counts) <-gsub("\\.bam$", "", colnames(counts))
colnames(counts) <- gsub(".*SRR", "SRR", colnames(counts)) 
colnames(counts) <- gsub("_1_trimmed.*", "", colnames(counts)) 
colnames(counts) <- gsub("\\..*", "", colnames(counts))

common_samples <- intersect(colnames(counts), rownames(meta))

if (length(common_samples) == 0) {
    messaggio <- paste("\n\n#####################################################\n",
                       "ERRORE FATALE: I nomi dei campioni non combaciano!\n",
                       "Nomi nella Matrice: ", paste(colnames(counts), collapse=" , "), "\n",
                       "Nomi nel Samplesheet: ", paste(rownames(meta), collapse=" , "), "\n",
                       "#####################################################\n\n")
    stop(messaggio)
}

counts <- counts[, common_samples]
meta <- meta[common_samples, , drop=FALSE]

design_formula <- as.formula(paste("~", user_design))

dds <- DESeqDataSetFromMatrix(countData = counts, colData = meta, design = design_formula)
keep <- rowSums(counts(dds)) >= 10
dds <- dds[keep,]
dds <- estimateSizeFactors(dds, type = "poscounts")
dds <- DESeq(dds)
res <- results(dds)

write.csv(as.data.frame(res), "risultati_analisi_differenziale.csv")

pdf ("deseq2_plots.pdf")
plotMA(res, main="MA Plot (test nf-core)")
dev.off()
