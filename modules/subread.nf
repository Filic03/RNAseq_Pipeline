process FEATURECOUNTS {
    tag "Tutti_i_campioni"
    label 'process_high'
    container 'quay.io/biocontainers/subread:2.0.6--he4a0461_0'

publishDir "${params.outdir}/featureCounts", mode: 'copy'

    input:
    path gtf
    path bams

    output:
    path "*.txt"        , emit: counts
    path "*.txt.summary", emit: summary

    script:
    
    def paired = params.single_end ? "" : "-p"
    """
    featureCounts $paired -a $gtf -o matrice_conteggi.txt -T ${task.cpus} -g ${params.g} -s ${params.strandedness} $bams
    """
}
