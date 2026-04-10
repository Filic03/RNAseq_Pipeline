process FASTQC {
tag "FastQC su ${sample_id}"
publishDir "${params.outdir}/01_fastqc", mode: 'copy'

input:
tuple val(sample_id), path(reads)

output:
path "*.{html,zip}"

script:
"""

${params.fastqc_bin} ${reads}
"""
}
