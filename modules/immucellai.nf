process IMMUCELLAI {
    tag "TME Deconvolution v2"
    label 'process_high'

    publishDir "${params.outdir}/deconvolution", mode: 'copy'

    container 'quay.io/biocontainers/python:3.10'

    input:
    path featurecounts_output

    output:
    path "tpm_matrix.txt"           , emit: tpm_matrix
    path "ImmuCellAI2_results.txt"  , emit: fractions

    script:
    """
    pip install --default-timeout=1000 pandas immucellai2

    python ${projectDir}/bin/run_immucellai2.py ${featurecounts_output} ${task.cpus}
    """
}
