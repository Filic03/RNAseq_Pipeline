process ENRICHR {
    tag "Pathway Analysis"
    label 'process_low'

    publishDir "${params.outdir}/enrichr", mode: 'copy'

    container 'quay.io/biocontainers/r-enrichr:3.2--r42hc7247d7_0'

    input:
    path deseq2_results

    output:
    path "*.{csv,pdf}", emit: enrichr_results

    script:
    """
    Rscript ${projectDir}/bin/run_enrichr.R \\
        --input filtered_results.txt \\
        --databases "${params.enrichr_database}" \\
        --outdir .
    """
}
