nextflow.enable.dsl=2

include {RNA_SEQ_ANALYSIS} from './workflows/rnaseq_pipeline.nf'

workflow {
ch_reads = Channel.fromFilePairs(params.input_reads, checkIfExists: true)

RNA_SEQ_ANALYSIS(ch_reads)
}
