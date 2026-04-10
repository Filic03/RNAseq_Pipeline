nextflow.enable.dsl=2

include {RNA_SEQ_ANALYSIS} from './workflows/rnaseq_pipeline.nf'

workflow {
read_pairs_ch = Channel.fromFilePairs(params.input_reads, checkIfExists: true)

RNA_SEQ_ANALYSIS(read_pairs_ch)
}
