#!/usr/bin/env nextflow

nextflow.enable.dsl = 2
// Required for .scan operations
nextflow.preview.recursion=true

/*
========================================================================================
    PARAMETER VALUES
========================================================================================
*/
// reference indexes are expected to be in reference folder
params.input_read_dir = "test_in"
params.output_dir = "realtime_example_output"
params.process_existing_files = true

// ### Printout for user
log.info """
    ===================================================
    Cyclomics/Realtime_test : Cyclomics real-time example
    ===================================================
    Inputs:
        input_reads              : $params.input_read_dir
        Cmd line                 : $workflow.commandLine
"""

/*
========================================================================================
    Include statements
========================================================================================
*/
include {
    DummyPreProcess as RealtimePreprocess
    DummyPreProcess as ExistingPreprocess
    DummyProcess
    AgregateFiles
    Report
} from "./submodules"


/*
========================================================================================
    Workflow
========================================================================================
*/
workflow {
    /*
    ========================================================================================
    AA. Parameter processing 
    ========================================================================================
    */
    // check if we are collecting existing data
    if (params.process_existing_files) {
        pod5_files_initial = Channel.fromPath("${params.input_read_dir}/*.pod5")
    }
    else {
        pod5_files_initial = Channel.empty()
    }
    pod5_files_initial.dump(tag: "existing-files")

    pod5_files = Channel.watchPath("${params.input_read_dir}/*.pod5",'create,modify')
        .until{file -> file.name == 'DONE.pod5'}
    pod5_files.dump(tag: "realtime-collect")

    // pod5_files_initial = pod5_files_initial.concat(pod5_files)
    pod5_files_initial = pod5_files_initial.map(x -> [x.Parent.simpleName, x.simpleName,x])
    pod5_files = pod5_files.map(x -> [x.Parent.simpleName, x.simpleName,x])
    pod5_files.dump(tag: "preanalysis-pod5")

    ExistingPreprocess(pod5_files_initial)
    RealtimePreprocess(pod5_files)

    DPP = ExistingPreprocess.out.concat(RealtimePreprocess.out)
    DummyProcess(DPP)
    // proccessed_pod5_files = DummyProcess.out.map(it -> it[2])
    // DummyProcess.dump(tag: 'processed_pod5')
    aggregate = AgregateFiles.scan(DummyProcess.out.map{tag,other_tag,file -> file })
    Report(aggregate)
}

workflow.onComplete {
	log.info ( workflow.success ? "\nDone. The results are available in following folder --> $params.output_dir\n" : "something went wrong in the pipeline" )
}
