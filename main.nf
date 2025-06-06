include { ingest      } from './subworkflows/ingest'
include { process_run } from './subworkflows/process_run'
include { run_module  } from './subworkflows/run_module'


workflow {
    if (params.output) {
        exit(1, "Please specify outdir with --outdir -- aborting")
    }
    if (params.out_dir) {
        exit(1, "Please specify outdir with --outdir -- aborting")
    }

    unique_id = "${params.unique_id}"

    if (unique_id == "null") {
        if (params.fastq) {
            fastq = file(params.fastq, type: "file", checkIfExists: true)
            unique_id = "${fastq.simpleName}"
        }
        else if (params.fastq_dir) {
            fastq_dir = file(params.fastq_dir, type: "dir", checkIfExists: true)
            unique_id = "${fastq_dir.simpleName}"
        }
        else if (params.paired || (params.fastq1 && params.fastq2)) {
            if (!params.paired) {
                exit(1, "Please run with --paired")
            }
            if (!params.fastq1 || !params.fastq2) {
                exit(1, "Both --fastq1 and --fastq2 must be provided")
            }
            fastq1 = file(params.fastq1, type: "file", checkIfExists: true)
            unique_id = "${fastq1.simpleName}"
        }
        else if (params.run_dir) {
            run_dir = file(params.run_dir, type: "dir", checkIfExists: true)
            unique_id = "${run_dir.simpleName}"
        }
        else {
            exit(1, "One of fastq, fastq_dir or fastq1 and fastq2 need to be provided -- aborting")
        }
    }

    // check input fastq exists and run fastp
    if (params.module) {
        run_module(unique_id)
    }
    else if (params.run_dir) {
        process_run(unique_id)
    }
    else {
        ingest(unique_id)
    }
}
