process DESEQ2 {
    tag "Analisi differenziale"
    label 'process_high'

    publishDir "${params.outdir}/deseq2", mode: 'copy'
   
    container 'quay.io/biocontainers/bioconductor-deseq2:1.38.0--r42hdfd78af_0'

    input:
    path counts       // La matrice generata da FeatureCounts
    path samplesheet  // Il tuo file CSV con i metadati

    output:
    path "*.csv", emit: results_csv
    path "*.pdf", emit: results_pdf

    script:
    """
  
    run_deseq2.R $counts $samplesheet ${params.design}
    """
}
