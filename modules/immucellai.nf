process IMMUCELLAI {
    tag "TME Deconvolution v2"
    label 'process_high'

    publishDir "${params.outdir}/deconvolution", mode: 'copy'

    container 'python:3.10-slim'

    input:
    path featurecounts_output

    output:
    path "tpm_matrix.txt"           , emit: tpm_matrix
    path "ImmuCellAI2_results.txt"  , emit: fractions

    script:
    """
  pip install --no-cache-dir --default-timeout=1000 pandas numba scipy tqdm joblib scikit-learn immucellai2

python ${projectDir}/bin/run_immucellai2.py ${featurecounts_output} ${task.cpus}
    """
}
