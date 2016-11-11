#!/bin/bash

PKG_NAME="freerdp_gui"

echo -n "Installing package FreeRDP GUI ... "

# installation directory
IDIR=/usr/local/share/$PKG_NAME

# global configuration directory
CDIR=/etc/$PKG_NAME

# install files
INSTALL="install -o root"
# create directories
sudo $INSTALL -m 755 -d $IDIR $IDIR/graphics $IDIR/functions $CDIR
# copy files
sudo $INSTALL -p -m 644 graphics/* -t $IDIR/graphics
sudo $INSTALL -p -m 644 functions/* -t $IDIR/functions
sudo $INSTALL -p -m 755 freerdp_gui.sh $IDIR
sudo $INSTALL -p -m 644 LICENSE $IDIR
sudo $INSTALL -p -m 644 etc/configuration $CDIR
sudo $INSTALL -p -m 644 freerdp-gui.desktop /usr/share/applications

echo "Done."
