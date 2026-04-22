process DESEQ2 {
    tag "Analisi differenziale"
    label 'process_high'

    publishDir "${params.outdir}/deseq2", mode: 'copy'
   
container 'quay.io/biocontainers/bioconductor-deseq2:1.50.2--r45ha27e39d_0'


    input:
    path counts     
    path samplesheet  

    output:
    path "*.csv", emit: results_csv
    path "*.pdf", emit: results_pdf

    script:
    """
    Rscript ${projectDir}/bin/run_deseq2.R $counts $samplesheet ${params.design}
    """
}
