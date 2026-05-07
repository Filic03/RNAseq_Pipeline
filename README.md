This is a Nextflow based pipeline for RNAseq Analysis.

-Felice Di Casola



<h1 align="center">
  🧬 FeliceDC/RNAseq_Pipeline
</h1>

<p align="center">
  ![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A523.04.0-23aa62.svg)
  ![Status](https://img.shields.io/badge/status-active-success.svg)
  ![STAR](https://img.shields.io/badge/aligner-STAR-blue)
  ![DESeq2](https://img.shields.io/badge/stats-DESeq2-purple)
</p>

## 📖 Introduction
**FeliceDC/RNAseq_Pipeline** is a bioinformatics analysis pipeline used for RNA sequencing data. Developed in Nextflow, it automates the entire workflow from raw FASTQ reads to Differential Expression analysis, ensuring reproducibility and scalability.

The pipeline is built using Docker/Singularity containers, meaning you don't need to install any bioinformatics tools manually.

> [!IMPORTANT]
> This pipeline automatically handles datasets with very small genomes (e.g., viral genomes or targeted panels) by bypassing standard dispersion curves in DESeq2, preventing crashes common in other public workflows.

## 🛠 Pipeline Summary
1. Raw read QC (`FastQC`)
2. Adapter and quality trimming (`Trim Galore!`)
3. Read alignment and indexing (`STAR`)
4. Gene-level quantification (`featureCounts`)
5. Pipeline QC report (`MultiQC`)
6. Differential Expression Analysis & Visualization (`DESeq2`)


## 🚀 Quick Start (Test Profile)

You can test the pipeline on your system without downloading heavy datasets. We have provided a self-contained `test` profile that runs on a minimal Sars-Cov-2 dataset.

```bash
nextflow run FeliceDC/RNAseq_Pipeline -profile test
```

If everything is set up correctly, this process will finish in less than a minute and generate the complete output folders.

## Usage with Real Data

To run the pipeline on your own samples, you need to provide:
1. Your raw fastq.gz files
2. A reference genome
3. An annotation file
4. A design matrix (named "samplesheet"). The samplesheet must be a comma-separated values file (.csv). The first column (called "sample") must match the FASTQ file names (excluding the _1.fastq.gz suffix), and the second column is the variable for the differential analysis. You can use a third column too for a double variables differential analysis.

## 📁 Output Structure
By default, the pipeline creates a results/ directory containing the following sub-directories:

fastqc/ & multiqc/: Interactive HTML quality reports.

star/: Sorted .bam files ready for IGV visualization.

featurecounts/: Raw count matrices.

deseq2/: CSV tables with statistically significant Differentially Expressed Genes (DEGs) and related plots (PCA, dispersion).

>[!WAIT]
>Running the pipeline on full human datasets requires significant computational resources. It is highly recommended to run the command inside a screen or tmux session, and specify an appropriate --max_cpus limit.


