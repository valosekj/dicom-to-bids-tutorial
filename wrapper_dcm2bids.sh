#!/bin/bash

# Wrapper to run dcm2bids on multiple subjects

SOURCEDATA="$1"

if [ ! -d "${SOURCEDATA}" ]; then
  echo "${SOURCEDATA} is not a folder." >&2
  exit 1
fi

CROSSWALK="$2"
if [ ! -f "${CROSSWALK}" ]; then
  echo "${CROSSWALK} is not a file." >&2
  exit 1
fi

PARTICIPANTS="participants.tsv"
if [ ! -f "${PARTICIPANTS}" ]; then
  echo "${PARTICIPANTS} is not a file." >&2
  exit 1
fi

# Loop through each line in the TSV file. Note that each row has several columns, separated by a tab.
# TODO: handle Windows newlines
while IFS=$'\t' read -r rhiscr_id imaging_id rest_of_line; do
    # map imaging_id to participant_id
    echo "rhiscr_id=|${rhiscr_id}|, imaging_id=|${imaging_id}|, rest_of_line=|${rest_of_line}|" # DEBUG

    participant_id="$(grep "$imaging_id" "$PARTICIPANTS" | awk '{print $1}')"

    if [ -z "$participant_id" ]; then
      echo "${imaging_id} not found in ${PARTICIPANTS}" >&2
      continue
    fi

    if [ ! -d "${SOURCEDATA}/${rhiscr_id} "*"/PAT01/DICOM/" ]; then
      echo "source DICOM folder for ${imaging_id} not found" >&2
      continue
    fi

    # run dcm2bids

    #DICOM=
    (set -x
    echo dcm2bids -d "${SOURCEDATA}/${rhiscr_id} "*"/PAT01/DICOM/" -p "${participant_id}" -c code/dcm2bids_config.json -o ./
    )
    #   -d -- source DICOM directory
    #   -p -- output participant ID
    #   -c -- JSON configuration file
    #   -o -- output BIDS directory
done < <(sed 's/\r$//' "$CROSSWALK")
#done < <(tail -n +2 participants.tsv)
# tail -n +2 participants.tsv: remove the first line of the file (header)
# <(...): this is a bash trick to read the output of a command as input of another command
