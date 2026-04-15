process STAR_INDEX {
    tag "$fasta"
    container 'quay.io/biocontainers/star:2.7.9a--h9ee0642_0'

    input:
    path fasta
    path gtf

    output:
    path "star_index", emit: index

    script:
    """
    mkdir star_index
    STAR --runMode genomeGenerate \\
         --genomeDir star_index \\
         --genomeFastaFiles $fasta \\
         --sjdbGTFfile $gtf \\
         --runThreadN ${task.cpus}
    """
}

process STAR_ALIGN {
    tag "$sample_id"
    container 'quay.io/biocontainers/star:2.7.9a--h9ee0642_0'

    input:
    path index
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("*.bam"), emit: bam
    path "*.Log.final.out"             , emit: log

    script:
    """
    STAR --genomeDir $index \\
         --readFilesIn $reads \\
         --readFilesCommand zcat \\
         --outFileNamePrefix ${sample_id}_ \\
         --outSAMtype BAM SortedByCoordinate \\
         --runThreadN ${task.cpus}
    """
}
