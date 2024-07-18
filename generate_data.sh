#!/bin/bash

# Initialize ITERATOR
ITERATOR=1
FOLDER="test_in"
SLEEPTIME=2

echo "Creating 2 dummy files in ${FOLDER} every ${SLEEPTIME} seconds."

while true; do
    # Generate filenames
    filename_a="a_${ITERATOR}.pod5"
    filename_b="b_${ITERATOR}.pod5"

    # Create files
    touch "$FOLDER/$filename_a"
    touch "$FOLDER/$filename_b"

    # Display confirmation message
    echo "Created files: $filename_a and $filename_b"

    # Increment ITERATOR
    ((ITERATOR++))

    # Sleep for 60 seconds
    sleep $SLEEPTIME
done