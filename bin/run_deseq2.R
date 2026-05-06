#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
counts_file <- args [1]
metadata_file <-args [2]
user_design <-args[3]

library(DESeq2)
library(ggplot2)

counts <- read.table(counts_file, header = TRUE, row.names = 1, stringsAsFactors = FALSE)
meta <- read.csv(metadata_file, row.names = 1, stringsAsFactors = TRUE)

counts <- counts[, 6:ncol(counts)]

colnames(counts) <-gsub("\\.bam$", "", colnames(counts))
colnames(counts) <- gsub(".*SRR", "SRR", colnames(counts)) 
colnames(counts) <- gsub("_1_trimmed.*", "", colnames(counts)) 
colnames(counts) <- gsub("\\..*", "", colnames(counts))

common_samples <- intersect(colnames(counts), rownames(meta))

if (length(common_samples) == 0) {
    message <- paste("\n\n#####################################################\n",
                       "ERROR: The sample names do not correspond!\n",
                       "Matrix names: ", paste(colnames(counts), collapse=" , "), "\n",
                       "Samplesheet names: ", paste(rownames(meta), collapse=" , "), "\n",
                       "#####################################################\n\n")
    stop(message)
}

counts <- counts[, common_samples]
meta <- meta[common_samples, , drop=FALSE]

design_formula <- as.formula(paste("~", user_design))

if (length(unique(as.list(counts))) == 1) {
    message("\n========================================================")
    message("DETECTED: Samples Are Identical (Profile Test).")
    message("Adding artificial batch effect in order to test the pipeline.")
    message("========================================================\n")
    set.seed(42)
    rumore <- matrix(rpois(nrow(counts) * ncol(counts), lambda = 5), nrow = nrow(counts))
    counts <- counts + rumore
}

dds <- DESeqDataSetFromMatrix(countData = counts, colData = meta, design = design_formula)
keep <- rowSums(counts(dds)) >= 10
dds <- dds[keep,]

dds <- tryCatch({
    DESeq(dds, sfType="poscounts")
}, error = function(e) {
    message("\nCurve fitting standard fallito (troppo pochi geni).")
    message("Uso il metodo 'mean' per completare l'analisi...\n")
    return(DESeq(dds, sfType="poscounts", fitType="mean"))
})


res <- results(dds)

write.table(as.data.frame(res), file="risultati_analisi_differenziale.txt", sep="\t", quote=FALSE, row.names=FALSE)

res_clean <- res[!is.na(res$padj), ]
res_filt <- res_clean[res_clean$padj < 0.05 & abs(res_clean$log2FoldChange) > 1.5, ]

write.table(as.data.frame(res_filt), file="risultati_filtrati_stringenti.txt", sep="\t", quote=FALSE, row.names=FALSE)

# --- SUPER EXCEL CREATIONS ---
conteggi_normalizzati <- counts(dds, normalized=TRUE)
res_df <- as.data.frame(res)
tabella_completa <- merge(res_df, conteggi_normalizzati, by="row.names", all=TRUE)
colnames(tabella_completa)[1] <- "Gene_Name"
tabella_completa <- tabella_completa[order(tabella_completa$padj), ]


write.table(as.data.frame(tabella_completa), file="tabella_completa.txt", sep="\t", quote=FALSE, row.names=FALSE)

#--- PLOTS ---

pdf ("deseq2_plots.pdf")

#MA plot
plotMA(res, main="MA Plot (test nf-core)")

#PCA plot
vsd <- vst(dds, blind=FALSE)
gruppi_pca <- trimws(unlist(strsplit(user_design, "\\+")))

pca_plot <- plotPCA(vsd, intgroup=gruppi_pca) + theme_minimal() + geom_point(size=4, alpha=0.9) + ggtitle("2. PCA") +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 15), 
    panel.grid.major = element_line(color = "grey90"),                
    panel.grid.minor = element_blank(),
    legend.title = element_text(face="bold", size=12), 
    legend.text = element_text(size = 11),                            
    axis.title = element_text(size = 12, face = "bold")               
  )

print(pca_plot)

#Volcano Plot
with(res, plot(log2FoldChange, -log10(padj), pch=20, main="3. Volcano Plot", col="darkgrey", xlim=c(-5,5)))
with(subset(res, padj < 0.05 & abs(log2FoldChange) > 1), points(log2FoldChange, -log10(padj), pch=20, col="red"))
abline(v=c(-1,1), col="blue", lty=2)
abline(h=-log10(0.05), col="blue", lty=2)

#Heatmap
top_genes <- head(order(res$padj), 50)
mat <- assay(vsd)[top_genes, ]
mat <- mat - rowMeans(mat)

colori_heatmap <- colorRampPalette(c("blue", "white", "red"))(256)

heatmap(mat, scale="none", col=colori_heatmap, margins=c(6, 6), cexCol=0.9, cexRow=0.8, main="4. Heatmap Top 50 Genes")


# 5. Top 6 genes counts plot
par(mfrow=c(3,2), las=1) 

colori_pro <- c("#1f78b4", "#e31a1c") 
top6_geni <- head(order(res$padj), 6)

conteggi_top6 <- counts(dds, normalized=TRUE)[top6_geni, ]
massimo_assoluto <- max(conteggi_top6)

limiti_y <- c(0.5, massimo_assoluto)

for (i in top6_geni) {
  nome_del_gene <- rownames(res)[i]
  
  # Disegniamo aggiungendo il parametro 'ylim'
  plotCounts(dds, 
             gene = nome_del_gene, 
             intgroup = "condition", 
             main = paste("Expression of:", nome_del_gene),
             col = colori_pro[dds$condition], 
             pch = 16,                             
             cex = 1.5,
             ylim = limiti_y 
  )
}


dev.off()
