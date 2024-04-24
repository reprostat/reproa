#!/bin/bash

# Config
CONFIGDIR=$HOME/.reproa

if [[ ! -d $CONFIGDIR ]]; then mkdir $CONFIGDIR; fi
if [[ -e $CONFIGDIR/reproa_parameters_user.xml ]]; then
    BCP="$CONFIGDIR/bcp-$(date +"%Y%m%d%H%M%S")_reproa_parameters_user.xml"
    echo "Configfile $CONFIGDIR/reproa_parameters_user.xml already exists, and it may not correspond to this installation!"
    echo "Existing configfile will be backed up as $BCP"
    echo "You may want to restore it after this execution"
    mv $CONFIGDIR/reproa_parameters_user.xml $BCP
fi
cp ${TOOLS_DIR}/reproa_bidsapp/parameters.xml $CONFIGDIR/reproa_parameters_user.xml

# Run
octave ${TOOLS_DIR}/reproa_bidsapp/reproa_bidsapp.m $@