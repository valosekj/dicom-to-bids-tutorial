# DICOM to BIDS conversion tutorial

## 1. Installation 

Install `dcm2bids` and `dcm2niix` tools, for example, by conda:

```console
# create conda environment
conda create --name dcm2bids python=3.8

# activate the environment
conda activate dcm2bids

# install dcm2bids and dcm2niix
conda install -c conda-forge dcm2bids dcm2niix
```

## 2. Explore your data

Assume you have the following dataset containing DICOM data for two subjects (subject `54321` and subject `65432`):

```console
$ tree
├── sourcedata
│	 ├── 54321
│	 │	 ├── 54321+00001+00001+00001.dcm
│	 │	 ├── 54321+00002+00001+00001.dcm
│	 │	 ├── 54321+00003+00001+00001.dcm
...
│	 └── 65432
│	     ├── 65432+00001+00001+00001.dcm
│	     ├── 65432+00002+00001+00001.dcm
│	     ├── 65432+00003+00001+00001.dcm
...
```

You can explore your source DICOM data by running the `dcm2bids_helper` command on a single subject:


```console
dcm2bids_helper -d sourcedata/54321
```

The `dcm2bids_helper` creates a `tmp_dcm2bids` folder. Check what is inside using the `ls` command:

```console
$ ls -1 tmp_dcm2bids/helper
001_54321_Localizer_20211019195649.json
001_54321_Localizer_20211019195649.nii.gz
002_54321_T1w_20211019195649.json
002_54321_T1w_20211019195649.nii.gz
003_54321_T2w_20211019195649.json
003_54321_T2w_20211019195649.nii.gz
...
```

Check what is inside the sidecar JSON files using the `grep` command:

### T1w image

```console
# Check SeriesDescription
$ grep "SeriesDescription" tmp_dcm2bids/helper/002_54321_T1w_20211019195649.json
	"SeriesDescription": "T1w",
```

```console
# Check ProtocolName
$ grep "ProtocolName" tmp_dcm2bids/helper/002_54321_T1w_20211019195649.json
	"ProtocolName": "T1w",
```

### T2w image

```console
# Check SeriesDescription
$ grep "SeriesDescription" tmp_dcm2bids/helper/003_54321_T2w_20211019195649.json
	"SeriesDescription": "T2w",
```

```console
# Check ProtocolName
$ grep "ProtocolName" tmp_dcm2bids/helper/003_54321_T2w_20211019195649.json
	"ProtocolName": "T2w"
```


## 3. Create JSON config file

The `dcm2bids` command requires the JSON config file.

Example of `dicom_to_bids_config.json` JSON config file:

```json
{
    "descriptions": [
        {
            "dataType": "anat",
            "modalityLabel": "T1w",
            "criteria": {
                "SeriesDescription": "T1w",
                "ProtocolName": "T1w"
            }
        },
        {
            "dataType": "anat",
            "modalityLabel": "T2w",
            "criteria": {
                "SeriesDescription": "T2w",
                "ProtocolName": "T2w"
            }
        }
    ]
}
```

## 4. Create `participants.tsv` file

To encode the source DICOM subjects (subject `54321` and subject `65432`) to the output BIDS subjects (subject `sub-001` and subject `sub-002`), we need to know the conversion logic.

The `participants.tsv` file contains `participant_id` and `source_id` columns, which can be used for this conversion. Thus, create the following `participants.tsv ` file as follow:

```
participant_id	source_id	sex	age
sub-001	54321	M	30
sub-002	65432	F	20
```

Note: besides the `participant_id` and `source_id` columns, you can include other useful columns, such as `sex` and `age`. See the `participants.tsv` template [here](https://intranet.neuro.polymtl.ca/data/dataset-curation.html#participants-tsv).

## 5. Run the conversion

You can run the `dcm2bids` conversion across all subjects using the wrapper script. Note that the wrapper script automatically reads the `participant_id` and `source_id` columns from the `participants.tsv` file.

```console
# make sure that the conda environment is activated
conda activate dcm2bids
```

```console
# run the wrapper script
./wrapper_dcm2bids.sh
```

```console
# deactivate the conda environment
conda deactivate
```

## 6. Check the output

You can check the `dcm2bids` output by `ls` or `tree` commands:


```console
$ tree
├── sub-001
│	 └── anat
│	     ├── sub-001_T1w.json
│	     ├── sub-001_T1w.nii.gz
│	     ├── sub-001_T2w.json
│	     └── sub-001_T2w.nii.gz
├── sub-002
│	 └── anat
│	     ├── sub-002_T1w.json
│	     └── sub-002_T1w.nii.gz
└── tmp_dcm2bids
    ├── log
    │	 ├── sub-001_2023-03-07T100438.296885.log
    │	 └── sub-002_2023-03-07T100446.227235.log
    ├── sub-001
    │	 ├── 001_54321_Localizer_20211019195649.json
    │	 ├── 001_54321_Localizer_20211019195649.nii.gz
    │	 ├── 005_54321_DWI_20211019195649.json
    │	 ├── 005_54321_DWI_20211019195649.nii.gz
    │	 ├── 006_54321_DWI_20211019195649.json
    │	 ├── 006_54321_DWI_20211019195649.nii.gz
    │	 ├── 007_54321_DWI_20211019195649.json
    │	 ├── 007_54321_DWI_20211019195649.nii.gz
    │	 ├── 008_54321_DWI_20211019195649.json
    │	 ├── 008_54321_DWI_20211019195649.nii.gz
    │	 ├── 010_54321_DWI_20211019195649.json
    │	 └── 010_54321_DWI_20211019195649.nii.gz
    └── sub-002
        ├── 001_65432_Localizer_20211102170757.json
        └── 001_65432_Localizer_20211102170757.nii.gz
```

