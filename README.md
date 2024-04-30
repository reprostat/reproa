# ReproAnalysis BIDS App

## Description

[BIDS App](http://bids-apps.neuroimaging.io) containing an instance of the [_reproa_ software](http://github.com/reprostat/reproanalysis) running under [Octave](https://octave.org) with minimum dependencies, including
- [BIDS Validator](https://github.com/bids-standard/bids-validator)
- [SPM](http://www.fil.ion.ucl.ac.uk/spm)

## Documentation

More documentation can be found at [the ReproStat project website](http://github.com/reprostat).

## Usage

### Notes on figure and video generation
Octave relies on a QT backend for graphics. It requires access to the display, which must be provided by passing a couple of variables and volumes to the container. The processing pipeline uses a couple of Octave packages, which will be downloaded and installed if needed. It requires access to the internet, which must be provided by passing `--network=host` to the container. Therefore, the list of parameters for launching the instance of the container may be more exhaustive than for other BIDS Apps.

### Format
To launch an instance of the container and analyse some data in BIDS format, type:

```bash
$ docker run -ti --rm \
	--user $(id -u):$(id -g) --env="DISPLAY" --env="HOME" --env="XDG_RUNTIME_DIR" --volume="$HOME:$HOME:rw" --volume="/dev:/dev:rw" --volume="/run/user:/run/user:rw" \
	--network=host \
	bids/reproa bids_dir output_dir <level> [--participant_label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...]] [--config CFG_FILE] [--skip_bids_validator]
```

For example, to run an analysis in ```participant``` level mode using the default (as descibed in SPM manual, chapter 30) workflow, type:

```bash
$ docker run -ti --rm \
	--user $(id -u):$(id -g) --env="DISPLAY" --env="HOME" --env="XDG_RUNTIME_DIR" --volume="$HOME:$HOME:rw" --volume="/dev:/dev:rw" --volume="/run/user:/run/user:rw" \
	--network=host \
  	-v /path/to/local/bids/input/dataset/:/data \
  	-v /path/to/local/output/:/output \
  	bids/reproa /data /output participant --participant_label 01
```

For example, to run an analysis in ```group``` level mode with a user-defined workflow, type:

```bash
$ docker run -ti --rm \
	--user $(id -u):$(id -g) --env="DISPLAY" --env="HOME" --env="XDG_RUNTIME_DIR" --volume="$HOME:$HOME:rw" --volume="/dev:/dev:rw" --volume="/run/user:/run/user:rw" \
	--network=host \
	-v /path/to/local/bids/input/dataset/:/data \
	-v /path/to/local/output/:/output \
	-v /path/to/local/cfg/:/cfg \
	bids/reproa \
	/data /output group --config /cfg/my_workflow_group.json
```

To build the container, type:

```bash
$ docker build -t <yourhandle>/reproa .
```

### Configuration file

The configuration file is an OCTAVE script detailing the analysis workflow to be executed. It has two parts:

#### Specifaction of the tasklist
The first part specifies the tasklist.

#### Parametrisation of the tasklist
The second part customises the tasklist.

```matlab
```

## Error Reporting

If you have a specific problem with the ReproAnalysis BIDS App, please open an [issue](https://github.com/reprostat/reproa/issues) on GitHub.

If your issue concerns ReproAnalysis more generally, please open an [issue](https://github.com/reprostat/reproanalysis/issues) on GitHub.
