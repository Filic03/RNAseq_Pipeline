process IMMUCELLAI {
    tag "Immune Deconvolution"
    label 'process_high'

    publishDir "${params.outdir}/deconvolution", mode: 'copy'

    container 'quay.io/biocontainers/r-base:4.3.1'

    input:
    path featurecounts_output

    output:
    path "tpm_matrix.txt"          , emit: tpm_matrix
    path "ImmuCellAI_fractions.txt", emit: fractions

    script:
    """
    Rscript ${projectDir}/bin/calculate_tpm.R ${featurecounts_output}

    Rscript ${projectDir}/bin/run_immucellai.R tpm_matrix.txt
    """
}
