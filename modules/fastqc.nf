process FASTQC {
    tag "FASTQC su $sample_id"
    label 'process_high'

    container 'biocontainers/fastqc:v0.11.9_cv8'

    input:
    tuple val(sample_id), path(reads)

    output:
    path "*.html", emit: html
    path "*.zip" , emit: zip

    script:
    """
    fastqc $reads
    """
}
