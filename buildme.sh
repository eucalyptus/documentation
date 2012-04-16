#!/bin/sh
#simple build script
export DITA_HOME="`pwd`/DITA-OT"
export DOC_HOME=`pwd`
export ANT_HOME="/usr/bin/ant"

sh DITA-OT/startcmd.sh

cd install_guide ; cp build.properties.buildy build.properties

ant pdf
