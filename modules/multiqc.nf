process MULTIQC {
    label 'process_high'
    
    publishDir "${params.outdir}/multiqc", mode: 'copy'

    container 'quay.io/biocontainers/multiqc:1.14--pyhdfd78af_0'

    input:
    path multiqc_files 

    output:
    path "multiqc_report.html", emit: report
    path "multiqc_data"       , emit: data

    script:
    """
    multiqc .
    """
}
