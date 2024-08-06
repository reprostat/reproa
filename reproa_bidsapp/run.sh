#!/bin/bash

# Config
CONFIGDIR=$HOME/.reproa

if [[ ! -d $CONFIGDIR ]]; then mkdir $CONFIGDIR; fi
if [[ -e $CONFIGDIR/reproa_parameters_user.xml ]]; then
    BCP="$CONFIGDIR/bcp-$(date +"%Y%m%d%H%M%S")_reproa_parameters_user.xml"
    echo ""
    echo "!!! WARNING !!!"
    echo "Configfile $CONFIGDIR/reproa_parameters_user.xml already exists, and it may correspond to your local installation rather than the container!"
    echo "Existing configfile will be backed up as $BCP"
    echo "You may want to restore it after this execution so that your local installation works as before."
    echo "!!! WARNING !!!"
    echo ""
    mv $CONFIGDIR/reproa_parameters_user.xml $BCP
fi
cp ${TOOLS_DIR}/reproa_bidsapp/parameters.xml $CONFIGDIR/reproa_parameters_user.xml

# Run
octave ${TOOLS_DIR}/reproa_bidsapp/reproa_bidsapp.m $@