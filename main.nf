#!/usr/bin/env nextflow

// recursion required for .scan operations
nextflow.enable.dsl = 2
nextflow.preview.recursion=true

/*
========================================================================================
    PARAMETER VALUES
========================================================================================
*/
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
        process_existing_files   : $params.process_existing_files
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
    // We need to seperately collect and process the existing and new files.
    // since currently it is not implemented to concat watchpath with frompath channels.
    // After doing a process step the results can be merged.

    // check if we are collecting existing data
    if (params.process_existing_files) {
        pod5_files_initial = Channel.fromPath("${params.input_read_dir}/*.pod5")
    }
    else {
        pod5_files_initial = Channel.empty()
    }
    // Realtime collection
    pod5_files = Channel.watchPath("${params.input_read_dir}/*.pod5",'create,modify')
        .until{file -> file.name == 'DONE.pod5'}

    // Convert the files into a tuple with ID of the file, as well as the ID of the parent folder.
    // In the future this allows for seperate analysis of barcoded runs.
    pod5_files_initial = pod5_files_initial.map(x -> [x.Parent.simpleName, x.simpleName,x])
    pod5_files = pod5_files.map(x -> [x.Parent.simpleName, x.simpleName,x])
    
    // Check inputs using the `-dump-channels` flag
    pod5_files_initial.dump(tag: "existing-files")
    pod5_files.dump(tag: "realtime-collect")

    ExistingPreprocess(pod5_files_initial)
    RealtimePreprocess(pod5_files)
    // Now we can merge both data sources.
    preprocessed_data = ExistingPreprocess.out.concat(RealtimePreprocess.out)
    DummyProcess(preprocessed_data)
    // Only feed the file into the agregator, as scan does not accept tuples elegantly currently.
    aggregate = AgregateFiles.scan(DummyProcess.out.map{tag,other_tag,file -> file })
    
    Report(aggregate)
}

workflow.onComplete {
	log.info ( workflow.success ? "\nDone. The results are available in following folder --> $params.output_dir\n" : "something went wrong in the pipeline" )
}
