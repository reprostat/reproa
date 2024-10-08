# ReproAnalysis BIDS App

[![Docker Image Version](https://img.shields.io/docker/v/reprostat/reproa)](https://hub.docker.com/r/reprostat/reproa) [![CircleCI](https://dl.circleci.com/status-badge/img/gh/reprostat/reproa/tree/master.svg?style=shield)](https://dl.circleci.com/status-badge/redirect/gh/reprostat/reproa/tree/master)

## Description

[BIDS App](http://bids-apps.neuroimaging.io) containing an instance of the [ReproAnalysis (_reproa_) software](http://github.com/reprostat/reproanalysis) (core only) running under [Octave](https://octave.org) with minimum dependencies, including
- [BIDS Validator](https://github.com/bids-standard/bids-validator)
- [SPM](http://www.fil.ion.ucl.ac.uk/spm)

N.B.: As it is a core-only version, it supports only the use cases of ReproAnalysis without any extension.

## Documentation

More documentation can be found at the [ReproStat project website](http://github.com/reprostat).


## Usage

### Format
To launch an instance of the container and analyse some data in BIDS format, type:

```bash
$ docker run -ti --rm \
	--user $(id -u):$(id -g) --env="DISPLAY" --env="HOME" --env="XDG_RUNTIME_DIR" --volume="$HOME:$HOME:rw" --volume="/dev:/dev:ro" --volume="${XDG_RUNTIME_DIR}:${XDG_RUNTIME_DIR}:rw" \
	--network=host \
	bids/reproa bids_dir output_dir <level> [--participant_label PARTICIPANT_LABEL[,PARTICIPANT_LABEL ...]] --config TASKLIST,USERSCRIPT[--skip_bids_validator]
```

For example, to run an analysis in ```participant``` level mode, type:

```bash
$ docker run -ti --rm \
	--user $(id -u):$(id -g) --env="DISPLAY" --env="HOME" --env="XDG_RUNTIME_DIR" --volume="$HOME:$HOME:rw" --volume="/dev:/dev:ro" --volume="${XDG_RUNTIME_DIR}:${XDG_RUNTIME_DIR}:rw" \
	--network=host \
  	--volume=/path/to/local/bids/input/dataset/:/data \
  	--volume=/path/to/local/output/:/output \
	--volume=/path/to/local/cfg/:/cfg \
  	bids/reproa /data /output participant --participant_label 01 --config /cfg/tasklist.xml,/cfg/userscript.m
```

For example, to run an analysis in ```group``` level mode, type:

```bash
$ docker run -ti --rm \
	--user $(id -u):$(id -g) --env="DISPLAY" --env="HOME" --env="XDG_RUNTIME_DIR" --volume="$HOME:$HOME:rw" --volume="/dev:/dev:ro" --volume="${XDG_RUNTIME_DIR}:${XDG_RUNTIME_DIR}:rw" \
	--network=host \
	--volume=/path/to/local/bids/input/dataset/:/data \
	--volume=/path/to/local/output/:/output \
	--volume=/path/to/local/cfg/:/cfg \
	bids/reproa /data /output group --config /cfg/tasklist.xml,/cfg/userscript.m
```

### Notes on figure and video generation
Octave relies on a QT backend for graphics. It requires access to the display, which must be provided by passing a couple of variables and volumes to the container. The processing pipeline uses a couple of Octave packages, which will be downloaded and installed if needed. It requires access to the internet, which must be provided by passing `--network=host` to the container. Therefore, the list of parameters for launching this BIDS App may be more exhaustive than for other BIDS Apps.

### Notes on the configuration files
ReproAnalysis BIDS App requires configuration files to [specify the analysis workflow](#specification-of-the-workflow). Without them, you can only use the most basic functionalities, incluing accessing help and version info and running the BIDS validator.
Two files need to be provided:
- [tasklist](#tasklist)
- [user script](#user-script)

You can use the same files for the ReproAnalysis BIDS App as for the ReproAnalysis software unless described otherwise. Any path, of course, MUST correspond to that of the BIDS App rather than the local file system. See also the [Notes on output location](#notes-on-output-location).

#### Tasklist
The first file specifies workflow based on the tasklist. It is an XML file and follows the same structure as for the ReproAnalysis software. You can find examples in the test folder:
- [ds_114_test1.xml](tests/ds114_test1.xml)
- [ds_114_test2.xml](tests/ds114_test2.xml)

#### User script
The second file is the user script parametrising the workflow. It is an OCTAVE/MATLAB M-file and follows the same structure as for the ReproAnalysis software with a few exceptions. 
- You MUST NOT call `reproaSetup` and `reproaWorkflow` but consider them already executed based on the tasklist by the time of the execution of your script.
- You MUST NOT specify `rap.directoryconventions.rawdatadir`, as it is already set to point to the BIDS dataset. However, you MUST call `processBIDS`, as your customisation may define its behaviour.
- You MUST NOT specify `rap.acqdetails.root` and `rap.directoryconventions.analysisid`, as they will be set to point to the BIDS App output and the script name, respectively.

You can find examples in the test folder:
- [ds_114_test1.m](tests/ds114_test1.m)
- [ds_114_test2.m](tests/ds114_test2.m)

### Notes on output location
ReproAnalysis generates various HTML reports with link to diagnostic images of the analysis. ReproAnalysis uses full path so that moving the HTMLs does not break the references. 

#### Correcting paths in the report
By default, the report generated by the ReproAnalysis BIDS App MUST be exported to the local filesystem before browsing. As the container does not have access to the local filesystem, you have to use a local installtion of ReproAnalysis:
```matlab
exportReport('/path/to/the/local/output/<rap.directoryconventions.analysisid>','/new/path/to/the/exported/report')
```

#### Ensure correct paths during the analysis
You can avoid the need for correcting the paths by mounting the output as it is in your local filesystem. E.g.:
```bash
	...
	--volume=/path/to/local/output/:/path/to/local/output \
	...
	bids/reproa /data /path/to/local/output ...
```


## Development
To modify and re-build the container, go to the repo directory (check out first, if needed) and type:

```bash
$ docker build -t <yourhandle>/reproa .
```


## Error Reporting

If you have a specific problem with the ReproAnalysis BIDS App, please open an [issue](https://github.com/reprostat/reproa/issues) on GitHub.

If your issue concerns ReproAnalysis software, please open an [issue](https://github.com/reprostat/reproanalysis/issues) on GitHub.
