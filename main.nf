#!/usr/bin/env nextflow
import nextflow.util.BlankSeparatedList

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
process DummyPreProcess {
    publishDir "${params.output_dir}/${task.process.replaceAll(':', '/')}", pattern: "", mode: 'copy'
    
    input:
        tuple val(sample_id), val(file_id), path(my_file) 
    output:
        tuple val(sample_id), val(file_id),path("${my_file.SimpleName}_output.txt")

    script:
    """
    echo '${my_file}' > ${my_file.SimpleName}_output.txt
    MAX_SLEEP=5
    sleep \$((RANDOM % \$MAX_SLEEP + 1))
    """
}
process DummyProcess {
    publishDir "${params.output_dir}/${task.process.replaceAll(':', '/')}", pattern: "", mode: 'copy'
    
    input:
        tuple val(sample_id), val(file_id), path(my_file) 
    output:
        tuple val(sample_id), val(file_id),path("*_${my_file.name}")

    script:
    """
    cat ${my_file} > procecced_${my_file.name}
    """
}

// Nextflow scan does a silly thing where it feeds back the growing list of
// historical outputs. We only ever need the most recent output (the "state").
process AgregateFiles{
    publishDir "${params.output_dir}/${task.process.replaceAll(':', '/')}", pattern: "", mode: 'copy'
    
    input:
        path stats 

    output:
        path("*state.txt")
    script:
        def new_input = stats instanceof BlankSeparatedList ? stats.first() : stats
        def state = stats instanceof BlankSeparatedList ? stats.last() : "NOSTATE"
        String output = "all_stats.${task.index}.state.txt"
    """
    if [[ "$state" == "NOSTATE" ]]; then
        echo "No state the prepend"
    else
        echo "State the prepend"
        cat $state > ${output}
    fi
    
    cat $new_input >> ${output}

    """    
}

process Report {
    publishDir "${params.output_dir}/", pattern: "", mode: 'copy'
    
    input:
        path(my_file) 

    output:
        path("*report.html")

    script:
    """
    echo "report iteration:" > report.html
    echo $task.index >> report.html
    echo "contents for far" >> report.html
    cat $my_file >> report.html
    """
}

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
    // check environments
    // pod5_files = Channel.fromPath("${params.input_read_dir}/*.pod5")
    pod5_files = Channel.watchPath("${params.input_read_dir}/*.pod5",'create,modify')
        .map(x -> [x.Parent.simpleName, x.simpleName,x])
    
    // pod5_files.view()
    DummyPreProcess(pod5_files)
    DummyProcess(DummyPreProcess.out)
    // proccessed_pod5_files = DummyProcess.out.map(it -> it[2])
    // proccessed_pod5_files.dump(tag: 'processed_pod5')
    
    aggregate = AgregateFiles.scan(DummyProcess.out.map{tag,other_tag,file -> file })
    // AgregateFiles.view(it -> it.text)
    Report(aggregate)
}

workflow.onComplete {
	log.info ( workflow.success ? "\nDone. The results are available in following folder --> $params.output_dir\n" : "something went wrong in the pipeline" )
}
