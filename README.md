# Realtime epi2me 
experiment to test how to create a pipeline that picks up files from an input dir.
result should look like a report.html file showing the current files.

## Aim 
create a simple example of a real-time pipeline in nextflow.

## Steps to run:
1. create a folder called test_in
1. run the pipeline with `nextflow run main.nf --input_read_dir test_in --output_dir abc_out`. Optionally set -dump-channels
1. start the data generator using `bash generate_data.sh`

Note: it is also importable into epi2me

## Outcome
We are now able to process both existing and new files in a given input directory, and comine the results into a html report.
This behaviour is settable with a flag.
