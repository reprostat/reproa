% reproa BIDS App
% based on https://github.com/bids-apps/SPM/blob/master/spm_BIDS_App.m
%
%   reproa:  http://github.com/reprostat/reproanalysis
%   BIDS: http://bids.neuroimaging.io
%   App:  https://github.com/reprostat/reproa
%
% See also:
%   BIDS Validator: https://github.com/bids-standard/bids-validator
%   Octave: https://octave.org
%   SPM: http://www.fil.ion.ucl.ac.uk/spm
%
% Copyright (C) 2023-2024 ReproImagine
% Tibor Auer

REPROADIR = '/opt/software/reproanalysis';

%% Initialise
setenv('DEBIAN_FRONTEND','noninteractive');
graphics_toolkit('qt');
addpath(REPROADIR)
reproaSetup()

%% Arguments
args = argv();

% Help
if isempty(args) || any(ismember({'-h' '--help'},args))
    fprintf([...
            'Usage: bids/reproa BIDS_DIR OUTPUT_DIR LEVEL [OPTIONS]\n',...
            '       bids/reproa [ -h | --help | -v | --version ]\n',...
            '\n',...
            'Mandatory inputs:\n',...
            '    BIDS_DIR        Input directory following the BIDS standard\n',...
            '    OUTPUT_DIR      Output directory\n',...
            '    LEVEL           Level of the analysis that will be performed\n',...
            '                    {participant,group}\n',...
            '\n',...
            'Options:\n',...
            '    --participant_label PARTICIPANT_LABEL [PARTICIPANT_LABEL ...]\n',...
            '                    Label(s) of the participant(s) to analyse\n',...
            '    --config CONFIG_FILE\n',...
            '                    Optional configuration M-file describing\n',...
            '                    the analysis to be performed\n',...
            '    --skip_bids_validator\n',...
            '                    Skip BIDS validation\n',...
            '    -h, --help      Print usage\n',...
            '    -v, --version   Print version information and quit\n']);
    exit(0);
end

% Version
if any(ismember({'-v' '--version'},args))
    meta = jsonread(fullfile(REPROADIR,'.zenodo.json'));

    fprintf('Reproducible Analysis BIDS App %s (reproa version: %s\n',...            
            deblank(fileread('/version')),...
            meta.version);
    exit(0);            
end

% Parse arguments
indParamName = cellfun(@(a) ischar(a) && startsWith(a,'--'), args);
args(indParamName) = strrep(args(indParamName), '--', '');

argParse = inputParser;
argParse.addRequired('bidsdir',@ischar);
argParse.addRequired('outdir',@ischar);
argParse.addRequired('level',@(x) ischar(x) && ismember(x, {'participant' 'group'}));
argParse.addParameter('participant_label','',@(x) ischar(x) && ~isempty(x));
argParse.addParameter('config','',@ischar);
argParse.addSwitch('skip_bids_validator');
argParse.parse(args{:});
BIDSApp = argParse.Results