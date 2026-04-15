include { FASTQC } from '../modules/local/fastqc'

workflow RNA_SEQ_ANALYSIS {
log.info "Analisi RNA-seq iniziata..."
ch_reads = Channel.fromFilePairs(params.input_reads, checkIfExists: true)
FASTQC(ch_reads)
}
