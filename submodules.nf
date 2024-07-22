import nextflow.util.BlankSeparatedList


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
    maxForks = 1
    input:
        path(my_file) 

    output:
        path("*report.html")

    script:
    """
    ls
    create_report.py
    # echo "report iteration:" > report.html
    # echo $task.index >> report.html
    # echo "contents for far" >> report.html
    # cat $my_file >> report.html
    """
}