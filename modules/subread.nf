process FEATURECOUNTS {
    tag "$sample_id"
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
    featureCounts $paired \\
                  -a $gtf \\
                  -o ${sample_id}_counts.txt \\
                -T ${task.cpus} \\
                  $bam
    """
}
