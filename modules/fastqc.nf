process FASTQC {
    tag "FASTQC su $sample_id"
    label 'process_low'

    container 'biocontainers/fastqc:v0.11.9_cv8'

publishDir "${params.outdir}/fastqc", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    path "*.html", emit: html
    path "*.zip" , emit: zip

    script:
    """
    fastqc -t ${task.cpus} $reads
    """
}
