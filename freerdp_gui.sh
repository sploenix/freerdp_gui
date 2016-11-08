#!/bin/bash

# path where this script is stored
#[ "`dirname $0`" = "." ] && SPATH=`pwd` || SPATH=`dirname $0`
BASEDIR=/usr/local/share/freerdp_gui

# load functions
source $BASEDIR/functions/gui_functions_yad.sh
#source functions/gui_functions_yad.sh

# installation directory
IDIR=/usr/local/share/freerdp_gui
# global configuration file
CFILE=/etc/freerdp_gui/configuration
# user configuration directory
UCDIR=~/.freerdp_gui
# user configuration file
UCFILE="$UCDIR/config"
# log file
LFILE=$UCDIR/freerdp_gui.log
[ ! -d $UCDIR ] && mkdir $UCDIR
[ ! -f $UCFILE ] && touch $UCFILE

# verify that yad is installed
command -v yad >/dev/null 2>&1 || {
  gnome-terminal --hide-menubar -x bash -c "
  source ~/Dokumente/BASH/freerdp_gui/functions/bash_color_definitions.sh;
  echo -e \"${BRed}ERROR: You need to install YAD to use this program${COff}\";
  bash"
  exit
}

# check that required programs are installed
requireBinFile "xfreerdp xrandr yadx"

# get number of active displays
NUMDISPLAYS=`xrandr --listactivemonitors | grep "Monitors:" | cut -d" " -f2`
# identify primary display
PRIMARY_DISPLAY_LINE=`xrandr --listactivemonitors | grep '+\*'`
# get properties for primary display
PRIMARY_DISPLAY_NUM=`echo $PRIMARY_DISPLAY_LINE | cut -d':' -f1`
PRIMARY_DISPLAY_NAME=`echo $PRIMARY_DISPLAY_LINE | cut -d" " -f4`
PRIMARY_DISPLAY_RES=`echo $PRIMARY_DISPLAY_LINE  | cut -d" " -f3 | cut -d'/' -f1`
SELECTION_LIST="$PRIMARY_DISPLAY_NAME ($PRIMARY_DISPLAY_RES,Primär)"
# build display selection list
let NUMDISPLAYS-=1
for i in `seq 0 $NUMDISPLAYS`; do
  if [ ! "$PRIMARY_DISPLAY_NUM" -eq "$i" ]; then
    RANDR_DATA=`xrandr --listactivemonitors | grep "$i:"`
    DISPLAY_NAME=`echo $RANDR_DATA | cut -d" " -f4`
    DISPLAY_RES=`echo $RANDR_DATA | cut -d" " -f3 | cut -d'/' -f1`
    SELECTION_LIST="$SELECTION_LIST!$DISPLAY_NAME ($DISPLAY_RES)"
  fi
done

# read user configuration file
USERHOSTLIST=`cat $UCFILE | grep HOSTS | cut -d"\"" -f2 | sed "s/,/!/g"`
USERUSERLIST=`cat $UCFILE | grep USERS | cut -d"\"" -f2 | sed "s/,/!/g"`
USERDOMAINLIST=`cat $UCFILE | grep DOMAINS | cut -d"\"" -f2 | sed "s/,/!/g"`
USERSCREENRES=`cat $UCFILE | grep "LAST_USED_SCREEN_RESOLUTION" | cut -d"\"" -f2 | sed "s/,/!/g"`

# read system configuration file
SYSTEMHOSTLIST=`cat $CFILE | grep HOSTS | cut -d"\"" -f2 | sed "s/,/!/g"`
SYSTEMUSERLIST=`cat $CFILE | grep USERS | cut -d"\"" -f2 | sed "s/,/!/g"`
SYSTEMDOMAINLIST=`cat $CFILE | grep DOMAINS | cut -d"\"" -f2 | sed "s/,/!/g"`

# Generate host list from user and system host list
[ -n "$USERHOSTLIST" ] && HOSTLIST="$USERHOSTLIST!$SYSTEMHOSTLIST" || HOSTLIST=$SYSTEMHOSTLIST
# Generate user list from user and system user list
[ -n "$USERUSERLIST" ] && USERLIST="$USERUSERLIST!$SYSTEMUSERLIST" || USERLIST="`whoami`!$SYSTEMUSERLIST"
# Generate domain list from user and system domain list
[ -n "$USERDOMAINLIST" ] && DOMAINLIST="HOSTNAME!$USERDOMAINLIST!$SYSTEMDOMAINLIST" || DOMAINLIST="HOSTNAME!$SYSTEMDOMAINLIST"
# Generate screen resolution list
[ -n "$USERSCREENRES" ] && RESOLUTION_LIST="$USERSCREENRES!Fullscreen!1980x1020!1600x900!1366x768" || RESOLUTION_LIST="Fullscreen!1980x1020!1600x900!1366x768"

# open dialog for RDP User and Password
DATA=$(yad --title="FreeRDP Connection Manager" \
  --image=$IDIR/graphics/preferences-desktop-remote-desktop.png \
  --text="\n\tNew RDP connection!\n" \
  --form \
  --field="Select computer":CBE \
          "$HOSTLIST" \
  --field="____________________________________________________________":LBL TRUE \
  --field="User Name":CBE "$USERLIST" \
  --field="Domain Name":CBE "$DOMAINLIST" \
  --field="Password":H "" \
  --field="____________________________________________________________":LBL TRUE \
  --field="Select Screen":CB "$SELECTION_LIST" \
  --field="Choose Screen Resolution":CB "$RESOLUTION_LIST"\
  --field="Security":CB 'nla!rdp!tls' \
  --button $BUTTON_CONNECT)

# handle EXITCODE using function exitCodeHandler
EXITCODE=$?
exitCodeHandler

# parse data
RDPHOST="`echo $DATA | cut -d'|' -f1`"
RDPUSER="`echo $DATA | cut -d'|' -f3`"
RDPDOMAIN="`echo $DATA | cut -d'|' -f4`"
RDPPASS="`echo $DATA | cut -d'|' -f5`"
DISP_SELECT="`echo $DATA | cut -d'|' -f7`"
RESOLUTION="`echo $DATA | cut -d'|' -f8`"
ENCRYPTION="`echo $DATA | cut -d'|' -f9`"

WIDTH="`echo $RESOLUTION | cut -d'x' -f1`"
HEIGHT="`echo $RESOLUTION | cut -d'x' -f2`"

# get num of selected display
DISPLAY_NAME=`echo $DISP_SELECT | cut -d' ' -f1`
SELECTED_DISPLAY=`xrandr --listactivemonitors | grep " $DISPLAY_NAME" | cut -d" " -f2 | cut -d":" -f1`

# generate screen resolution string
[ "$RESOLUTION" == "Fullscreen" ] && RESOLUTION_STRING="/monitors:$SELECTED_DISPLAY /f" || RESOLUTION_STRING="/w:$WIDTH /h:$HEIGHT"

# store resolution to configuration file
STR="LAST_USED_SCREEN_RESOLUTION"
UCRESSTRING=`grep "$STR=\"" $UCFILE | cut -d"\"" -f2`
[ -z "$UCRESSTRING" ] && {
  echo "Adding $STR entry to configuration file"
  echo "$STR=\"$RESOLUTION\"" >> $UCFILE
} || {
  sed "s/$STR=\"$UCRESSTRING\"/$STR=\"$RESOLUTION\"/g" -i $UCFILE
}

# store host in user configuration file
UCHOSTSTRING=`grep "HOSTS=\"" $UCFILE | cut -d"\"" -f2`
UCUSERSTRING=`grep "USERS=\"" $UCFILE | cut -d"\"" -f2`
UCDOMAINSTRING=`grep "DOMAINS=\"" $UCFILE | cut -d"\"" -f2`

# store host and user in user configuration file
[ -z `echo $UCHOSTSTRING | grep $RDPHOST` ] && {
  echo "Adding host $RDPHOST to user configuration file"
  # if user configuration file has no hosts entry
  [ -z "$UCHOSTSTRING" ] && {
    echo "Adding HOSTS entry to configuration file"
    echo "HOSTS=\"$RDPHOST\"" >> $UCFILE
  } || sed "s/HOSTS=\"$UCHOSTSTRING\"/HOSTS=\"$RDPHOST,$UCHOSTSTRING\"/g" -i $UCFILE
}
# cut domain name from user name (domain definition in user name has preference over domain name field
echo $RDPUSER | grep "\\\\"
[ -n "`echo $RDPUSER | grep '\\\\'`" ] && {
  RDPDOMAIN=`echo $RDPUSER | cut -d'\' -f1`
  RDPUSER=`echo $RDPUSER | cut -d'\' -f2`
}
# store user in user configuration file
[ -z `echo $UCUSERSTRING | grep $RDPUSER` ] && {
  echo "Adding user $RDPUSER to user configuration file"
  # if user configuration file has no users entry
  [ -z "$UCUSERSTRING" ] && {
    echo "Adding USERS entry to configuration file"
    echo "USERS=\"$RDPUSER\"" >> $UCFILE
  } || {
    sed "s/USERS=\"$UCUSERSTRING\"/USERS=\"$RDPUSER,$UCHOSTSTRING\"/g" -i $UCFILE
  }
}
# store domain name if it's not the hostname
if [[ "$RDPDOMAIN" != "HOSTNAME" && "$RDPDOMAIN" != "$RDPHOST" ]]; then
  [ -z `echo $UCDOMAINSTRING | grep $RDPDOMAIN` ] && {
    echo "Adding domain $RDPDOMAIN to user configuration file"
    # if user configuration file has no users entry
    [ -z "$UCDOMAINSTRING" ] && {
      echo "Adding DOMAINS entry to configuration file"
      echo "DOMAINS=\"$RDPDOMAIN\"" >> $UCFILE
    } || {
      sed "s/DOMAINS=\"$UCDOMAINSTRING\"/DOMAINS=\"$RDPDOMAIN,$UCDOMAINSTRING\"/g" -i $UCFILE
    }
  }
else
  RDPDOMAIN=$RDPHOST
fi

# check if password was given
# if not we have to ask again
[ -z "$RDPPASS" ] && RDPPASS=$(yad --form --field="Please enter password for user $RDPUSER on host $RDPHOST  ":H)
RDPPASS=`echo $RDPPASS | cut -d'|' -f1`

[ -z "$RDPPASS" ] && {
  DATA=$(yad --title="ERROR: FreeRDP Connection Manager" \
    --image=$IDIR/graphics/application-exit.png \
    --text="\n\tNo password given!\t\n" )
  exit
}

# generate connection command
COMMAND="xfreerdp \
/u:"$RDPUSER" \
/d:"$RDPDOMAIN" \
/v:$RDPHOST \
$RESOLUTION_STRING \
/gdi:hw \
+clipboard \
+compression \
+home-drive \
+multitransport  \
/sec:$ENCRYPTION \
/cert-ignore \
-wallpaper \
-themes"

# store connection command in log file
echo -e "$COMMAND /p:**SECRETPASS**"> $LFILE

# open rdp connection
$COMMAND /p:$RDPPASS >> $LFILE
