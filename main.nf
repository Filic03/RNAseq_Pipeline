nextflow.enable.dsl=2

include {RNA_SEQ_ANALYSIS} from './workflows/rnaseq_pipeline'

workflow {
RNA_SEQ_ANALYSIS()
}
