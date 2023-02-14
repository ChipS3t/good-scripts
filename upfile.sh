#!/bin/bash

# Check if a file path argument was provided
if [ $# -eq 0 ]
then
    echo "Error: No file path argument provided"
    exit 1
fi

# Store the file path argument in a variable
files=("$@")

for file in "${files[@]}"; do
    # Expand the wildcard character and store the list of files in a variable
    expanded_files=$(ls "$file")

    # Print each file in the list
    for expanded_file in $expanded_files; do
        # Execute the curl command and store the output in a variable
        output=$(curl -s -F "file=@$file" https://tmpfiles.org/api/v1/upload)

        # Check if the output contains an error message
        if echo "$output" | grep -iq '"server error"'
        then
            # Print an error message and exit
            echo "Error: Server error"
            exit 1
        fi

        # Extract the 6 digit number that identifies the result
        id="$(echo $output | sed -n 's/.*\/\([0-9]\{6\}\)\/.*/\1/p')"
        
        # Print the first part of the url
        printf "https://tmpfiles.org/dl/"
        
        # Set the text attribute to bold
        tput bold
        
        # Print the 6 digit number
        printf "%s" "${id}"
        
        # Reset the text attribute to the default
        tput sgr0
        
        # Print the rest of the url
        printf "/%s\n" "${expanded_file}"
    done
done
