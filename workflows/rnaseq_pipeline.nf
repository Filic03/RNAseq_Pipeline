include {FASTQC} from '../modules/fastqc.nf'
include {CUTADAPT} from '../modules/cutadapt.nf'

workflow RNA_SEQ_ANALYSIS {
	take:
		reads_ch

	main:
		FASTQC(reads_ch)
		CUTADAPT(reads_ch)

	emit:
		fastqc_results = FASTQC.out
		trimmed_reads = CUTADAPT.out.reads_trimmed

}
