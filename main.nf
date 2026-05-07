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

if (!params.input_reads || !params.fasta || !params.gtf) {
    exit 1, """
    ❌ WAIT!: Missing input parameters!
    
    You must specify the file paths
    
    Required parameters:
      --input_reads   : Path to FASTQ files (es. "data/*_{1,2}.fastq.gz")
      --fasta         : Reference genome in FASTA format (es. "genome.fa")
      --gtf           : Annotation file in GTF format (es. "annotation.gtf")
      
    Usage example:
    nextflow run main.nf \\
      --input_reads "my_data/*_{1,2}.fastq.gz" \\
      --fasta "ref/genome.fa" \\
      --gtf "ref/annotation.gtf" \\
      --design "condition" \\
      --samplesheet "my_samplesheet.csv"
    =======================================================
    """
}

workflow.onComplete {
    def msg = """\
        Pipeline execution summary
        ---------------------------
        Completed at: ${workflow.complete}
        Duration    : ${workflow.duration}
        Success     : ${workflow.success}
        workDir     : ${workflow.workDir}
        exit status : ${workflow.exitStatus}
        """
        .stripIndent()

    println msg

    if (workflow.success) {
        println "✅ Analisi completata con successo! I risultati sono in: ${params.outdir}"
    } else {
        println "❌ Ops... la pipeline si è interrotta con un errore."
    }

    if (params.email) {
        try {
            sendMail(to: params.email, subject: "RNAseq Pipeline - Status", body: msg)
            println "📧 Email di notifica inviata correttamente a: ${params.email}"
        } catch (Exception e) {
            println "⚠️ Impossibile inviare l'email. Controlla che il server supporti l'invio di posta."
        }
    }
}

include {RNA_SEQ_ANALYSIS} from './workflows/rnaseq_pipeline'

workflow {
RNA_SEQ_ANALYSIS()
}
