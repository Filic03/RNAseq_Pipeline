nextflow.enable.dsl=2

if (!params.design) {
    exit 1, """
    ❌ WAIT! The analysis cannot start: '--design' missing!
You must specify the column(s) of the samplesheet to use for differential analysis.
    
    Example:
    nextflow run main.nf --design "condition" -resume
    nextflow run main.nf --design "treatment + age" -profile test
    =======================================================
    """
}

include {RNA_SEQ_ANALYSIS} from './workflows/rnaseq_pipeline'

workflow {
RNA_SEQ_ANALYSIS()
}
