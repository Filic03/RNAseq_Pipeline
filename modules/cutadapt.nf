process CUTADAPT {
    tag "Trimming su ${sample_id}"
    publishDir "${params.outdir}/02_trimmed", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}_R1_clean.fastq.gz"), path("${sample_id}_R2_clean.fastq.gz"), emit: reads_trimmed
    path "${sample_id}_cutadapt_report.txt", emit: report

    script:
    """
    ${params.cutadapt_bin} \
        -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \
        -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
        -o ${sample_id}_R1_clean.fastq.gz \
        -p ${sample_id}_R2_clean.fastq.gz \
        ${reads[0]} ${reads[1]} \
        --minimum-length 20 > ${sample_id}_cutadapt_report.txt
    """
}

