#!/bin/bash

# path where this script is stored
[ "`dirname $0`" = "." ] && SPATH=`pwd` || SPATH=`dirname $0`
BASEDIR=`readlink -m $SPATH/../..`

# load system functions
#source $BASEDIR/functions/sys_functions.sh

PKG_NAME="freerdp_gui"

echo "Installing package FreeRDP GUI..."

# installation directory
IDIR=/usr/local/share/$PKG_NAME

# global configuration directory
CDIR=/etc/$PKG_NAME

# create directories if needed
[ ! -d $IDIR ] && sudo mkdir -p $IDIR
[ ! -d $CDIR ] && sudo mkdir -p $CDIR

# install files
INSTALL="install -o root"
sudo $INSTALL -m 755 -d graphics $IDIR/graphics
sudo $INSTALL -m 755 -d functions $IDIR/functions
sudo $INSTALL -m 755 freerdp_gui.sh $IDIR
sudo $INSTALL -m 644 graphics/* $IDIR/graphics
sudo $INSTALL -m 644 etc/configuration $CDIR
sudo $INSTALL -m 644 $BASEDIR/functions/bash_color_definitions.sh $IDIR/functions
sudo $INSTALL -m 644 $BASEDIR/functions/sys_functions.sh $IDIR/functions
sudo $INSTALL -m 644 $BASEDIR/functions/gui_functions_base.sh $IDIR/functions
sudo $INSTALL -m 644 $BASEDIR/functions/gui_functions_yad.sh $IDIR/functions
sudo $INSTALL -m 644 freerdp-gui.desktop /usr/share/applications
