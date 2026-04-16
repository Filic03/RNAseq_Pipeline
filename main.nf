nextflow.enable.dsl=2

include {RNA_SEQ_ANALYSIS} from './workflows/rnaseq_pipeline'
include { MULTIQC } from './modules/multiqc.nf'

workflow {
RNA_SEQ_ANALYSIS()
}
