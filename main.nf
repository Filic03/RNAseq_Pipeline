nextflow.enable.dsl=2

if (!params.design) {
    exit 1, """
    ❌ CRITICAL ERROR: '--design' missing!
You must specify the column of the sample sheet to use for differential analysis.
    
    Example:
    nextflow run main.nf --design "condition" -resume
    nextflow run main.nf --design "treatment" -profile test
    =======================================================
    """
}

include { RNA_SEQ_ANALYSIS } from './workflows/rnaseq_pipeline'

workflow {
    RNA_SEQ_ANALYSIS()
}


include {RNA_SEQ_ANALYSIS} from './workflows/rnaseq_pipeline'

workflow {
RNA_SEQ_ANALYSIS()
}
