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

dds <- DESeqDataSetFromMatrix(countData = counts, colData = meta, design = design_formula)
keep <- rowSums(counts(dds)) >= 10
dds <- dds[keep,]
dds <- DESeq(dds, sfType="poscounts")
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


#Top 6 Genes
library(ggplot2)

gruppi_design <- trimws(unlist(strsplit(user_design, "\\+")))
var_target <- tail(gruppi_design, n=1)

top6_geni <- head(order(res$padj), 6)

tutti_i_dati <- data.frame()


for (i in top6_geni) {
  nome_del_gene <- rownames(res)[i]
  dati_gene <- plotCounts(dds, gene=nome_del_gene, intgroup=var_target, returnData=TRUE)
  

  dati_gene$Gruppo <- dati_gene[[var_target]]
  dati_gene$Gene <- nome_del_gene 
  
  tutti_i_dati <- rbind(tutti_i_dati, dati_gene)
}

p <- ggplot(tutti_i_dati, aes(x=Gruppo, y=count, fill=Gruppo)) +
  stat_summary(fun = mean, geom = "crossbar", width = 0.4, color="gray50", size=0.5) +
  geom_jitter(width=0.1, size=3, shape=21, color="black", stroke=0.8) +
  scale_y_log10() +
  theme_minimal() +
  labs(title="Expression of Top 6 Differentially Expressed Genes", x="", y="Normalized Counts (log10)") +
  facet_wrap(~ Gene, ncol=2, scales="free_y") + 
  

  theme(
    plot.title = element_text(hjust=0.5, face="bold", size=16, margin=margin(b=20)),
    legend.position = "none",
    strip.text = element_text(size=12, face="bold", color="black"),
    strip.background = element_rect(fill="gray90", color=NA),       
    axis.text.x = element_text(size=11, face="bold", color="black"),
    axis.text.y = element_text(size=10, color="black"),
    panel.spacing = unit(1, "lines")                                
  ) +
  scale_fill_manual(values=c("#00ced1", "#fa8072", "#33a02c", "#ff7f00"))


dev.off()
