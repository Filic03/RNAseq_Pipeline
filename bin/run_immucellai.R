#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
tpm_file <- args[1]

if (!requireNamespace("devtools", quietly = TRUE)) {
    install.packages("devtools", repos="http://cran.us.r-project.org")
}
if (!requireNamespace("ImmuCellAI", quietly = TRUE)) {
    cat("Download dei pesi dell'Intelligenza Artificiale da GitHub...\n")
    devtools::install_github("lydiaMyr/ImmuCellAI")
}

library(ImmuCellAI)

cat("Loading TPM matrix..\n")
tpm_matrix <- read.table(tpm_file, header=TRUE, row.names=1, sep="\t")

cat("Starting ImmuCellAI prediction of immune cell populations...\n")

ia_results <- ImmuCellAI_new(sample_expr = tpm_matrix, data_type = "rnaseq", group_info = NULL)

write.table(ia_results$Immune_cell_fraction, file="ImmuCellAI_fractions.txt", sep="\t", quote=FALSE, col.names=NA)
cat("Immune deconvolution completed\n")
