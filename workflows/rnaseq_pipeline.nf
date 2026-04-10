include {FASTQC} from '../modules/fastqc.nf'

workflow RNA_SEQ_ANALYSIS {
	take:
		reads_ch

	main:
		FASTQC(reads_ch)

	emit:
		fastqc_results: FASTQC.out

}
