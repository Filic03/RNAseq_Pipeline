include { FASTQC } from '../modules/fastqc'
include {TRIMGALORE} from '../modules/trimgalore'
include { STAR_INDEX; STAR_ALIGN } from '../modules/star'
include { FEATURECOUNTS } from '../modules/subread'
include { MULTIQC } from '../modules/multiqc'

workflow RNA_SEQ_ANALYSIS {
log.info "Analisi RNA-seq iniziata..."

if (params.single_end) {
ch_reads = Channel.fromPath(params.input_reads, checkIfExists: true)
                  .map {file -> tuple(file.simpleName, [file]) }
} else {
ch_reads = Channel.fromFilePairs(params.input_reads, checkIfExists: true)
}

FASTQC(ch_reads)
TRIMGALORE(ch_reads)

ch_fasta = file(params.fasta)
ch_gtf   = file(params.gtf)
STAR_INDEX(ch_fasta, ch_gtf)

STAR_ALIGN(STAR_INDEX.out.index, TRIMGALORE.out.reads)

FEATURECOUNTS(ch_gtf, STAR_ALIGN.out.bam)

    ch_multiqc_files = Channel.empty()
    ch_multiqc_files = ch_multiqc_files.mix(
        FASTQC.out.zip,
        TRIMGALORE.out.log,
        STAR_ALIGN.out.log,
        FEATURECOUNTS.out.summary
    )

    MULTIQC( ch_multiqc_files.collect() )

}
