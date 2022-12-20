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

        # Extract the URL value from the JSON output using bash string manipulation
        url=${output#*\"url\":\"}  # remove everything before "url":"
        url=${url%%\"*}  # remove everything after the first "

        # Extract the 6-digit number from the URL using a regular expression
        number=$(echo "$url" | grep -oE '[0-9]{6}')

        # Extract the first part of the URL up to the 6-digit number using a regular expression
        firstPart=$(echo "$url" | grep -oE 'https://tmpfiles.org/[^/]*')

        # Extract the last part of the URL (the filename and extension) using a regular expression
        lastPart=$(echo "$url" | grep -oE '/[^/]*$')

        # Print the first part of the URL up to the 6-digit number, without the 6-digit number itself
        printf "%s" "${firstPart%$number}"

        # Set the text attribute to bold
        tput bold

        # Print the 6-digit number in bold
        printf "%s" "$number"

        # Reset the text attribute to the default
        tput sgr0

        # Print the last part of the URL (the filename and extension)
        echo "$lastPart"
    done
done
