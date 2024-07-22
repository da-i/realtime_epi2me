import nextflow.util.BlankSeparatedList


process DummyPreProcess {
    // Put the orignal filename in a txt file, then sleep a random number of seconds (<5) to pretend to be busy.
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
    // in essence just rename the file.
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



process AgregateFiles{
    // Implemented to work with nextflow.preview.recursion: puts the contents of the input file 
    // into an ever growing file.
    // Nextflow scan does a silly thing where it feeds back the growing list of
    // historical outputs. We only ever need the most recent output (the "state").
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
    // Call the python script that makes a html report.
    publishDir "${params.output_dir}/", pattern: "", mode: 'copy'
    maxForks = 1
    input:
        path(my_file) 

    output:
        path("*report.html")

    script:
    """
    ls
    create_report.py
    """
}