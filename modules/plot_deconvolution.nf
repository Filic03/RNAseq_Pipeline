process PLOT_DECONVOLUTION {
    tag "Plot TME"
    label 'process_low'

    publishDir "${params.outdir}/deconvolution/plots", mode: 'copy'

    container 'python:3.10-slim'

    input:
    path immucellai_results

    output:
    path "*.pdf", emit: plots

    script:
    """
   
    pip install --no-cache-dir pandas openpyxl matplotlib seaborn

   
    python ${projectDir}/bin/plot_deconvolution.py ${immucellai_results}
    """
}
