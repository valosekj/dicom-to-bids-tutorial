#!/bin/bash

# Wrapper to run dcm2bids on multiple subjects

# Loop through each line in the TSV file. Note that each row has several columns, separated by a tab.
while IFS=$'\t' read -r participant_id source_id rest_of_line; do
    # run dcm2bids
    dcm2bids -d sourcedata/${source_id} -p ${participant_id} -c dicom_to_bids_config.json -o ./
    #   -d -- source DICOM directory
    #   -p -- output participant ID
    #   -c -- JSON configuration file
    #   -o -- output BIDS directory
done < <(tail -n +2 participants.tsv)
# tail -n +2 participants.tsv: remove the first line of the file (header)
# <(...): this is a bash trick to read the output of a command as input of another command
