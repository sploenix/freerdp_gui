#!/bin/bash

# Store PID of main calling script
# ...but only if the script is not called from another script
[ -z "$TOP_PID" ] && {
	trap "exit 1" TERM
	export TOP_PID=$$
}

# load bash color definitions
source $BASEDIR/functions/bash_color_definitions.sh

# bash implementation of GOTO
function jumpto {
  label=$1
	cmd=$(sed -n "/$label:/{:a;n;p;ba};" $0 | grep -v ':$')
	eval "$cmd"
	exit
}

function error() {
  [ -n "$1" ] && echo -e "${FAIL_MSG_COLOR}$1${COff}"
  kill -s TERM $TOP_PID
}

function exitScript() {
	[ -n "$1" ] && echo -e "${SYS_MSG_COLOR}$1${COff}"
  kill -s TERM $TOP_PID
}

function requireBinFile {
	for arg; do
		command -v $arg >/dev/null 2>&1 || error "Program $i not found..."
	done
}

function sysMessage() {
  [ -n "$2" ] && echo -e $1 "${MAIN_MSG_COLOR}$2${COff}" || echo -e "${MAIN_MSG_COLOR}$1${COff}"
}

function infoMessage() {
	sysMessage $1 $2
}

function okMessage() {
  [ -n "$2" ] && echo -e $1 "${OK_MSG_COLOR}$2${COff}" || echo -e "${OK_MSG_COLOR}$1${COff}"
}

function reverseHostLookup() {
	echo `drill -x $1 | grep PTR | tac | head -n 1 | awk '{print $5}'`
}

# verify that file is not older than a given time span
function fileIsRecent() {
  # if no time limit is given (in seconds), one day will be used
  [ -z "$2" ] && LIMIT=86400 || LIMIT=$2
  FILEDATE=`date -r $1 +%s`
  DATENOW=`date +%s`

  # return boolean value if file is not older than given limit
  [ "$((DATENOW-FILEDATE))" -gt "$LIMIT" ]
}

function getOS() {
  [ -f /etc/arch-release ] && {
    echo "ARCH"
    return 0
  }
  [ -f /etc/centos-release ] && {
    echo "CENTOS"
    return 0
  }
  [ -n "`cat /etc/issue | grep Ubuntu | cut -d' ' -f1`" ] && {
    echo "UBUNTU"
    return 0
  }
}

function addGPGKey() {
	TARGETKEY=$1
	SUDOUSERHOME=`getent passwd $SUDOUSER | cut -d':' -f6`
	KEYSERVER="hkp://pgp.mit.edu"
	# Add keyserver to gnupg config file for sudo user
	if [ -z "`cat $SUDOUSERHOME/.gnupg/gpg.conf | grep $KEYSERVER`" ]; then
		echo -e "${Blue}Adding keyserver to file ${COff}$SUDOUSERHOME/.gnupg/gpg.conf"
		echo "keyserver $KEYSERVER" >> $SUDOUSERHOME/.gnupg/gpg.conf
	fi
	if [ -z "`sudo -u $SUDOUSER gpg --list-keys | grep $TARGETKEY`" ]; then
		echo -e "${Blue}Fetching key ${COff}"
		sudo -u $SUDOUSER gpg --recv-keys $TARGETKEY
	fi
}

function systemdGetLoadState () {
  # grep status from systemctl
	LOAD_STATE=`systemctl status $1 | grep "Loaded:" | awk '{print $4}' | cut -d';' -f1`
  echo $LOAD_STATE
}

function systemdGetRunState () {
  # grep status from systemctl
	RUN_STATE=`systemctl status $1 | grep "Active:" | awk '{print $2}'`
  echo $RUN_STATE
}

function systemdIsDisabled () {
  # return logical status
  [ "`systemdGetLoadState $1`" == "disabled" ]
}

function systemdIsEnabled () {
  # return logical status
  [ "`systemdGetLoadState $1`" == "enabled" ]
}

function systemdIsRunning () {
  # return logical status
  [ "`systemdGetRunState $1`" == "active" ]
}

function systemdEnable() {
  SERVICE=$1
  # check wether service is enabled
  systemdIsDisabled $SERVICE && {
    echo -e "${MAIN_MSG_COLOR}Enabling systemd service $SERVICE...$COff"
    # enable service
    sudo systemctl enable $SERVICE
    # recheck wether service is enabled
    systemdIsDisabled $SERVICE && error "Failed to enable systemd service $SERVICE..."
  }
}

function systemdRun() {
  SERVICE=$1
  # check wether service is running
  ! systemdIsRunning $SERVICE && {
    echo -e "${MAIN_MSG_COLOR}Starting systemd service $SERVICE...$COff"
    # enable service
    sudo systemctl start $SERVICE
    # recheck wether service is running
    ! systemdIsRunning $SERVICE && error "Failed to start systemd service $SERVICE..."
  }
}

function systemdStop() {
  SERVICE=$1
  # check wether service is running
  systemdIsRunning $SERVICE && {
    sysMessage "Stopping systemd service $SERVICE..."
    # stop service
    sudo systemctl stop $SERVICE
    # recheck wether service is running
    systemdIsRunning $SERVICE && error "Failed to stop systemd service $SERVICE..."
  }
}

function requireRoot() {
	[ "`whoami`" = 'root' ] || error "This Script must be run as root!"
}

function requireNonRoot() {
  [ "`whoami`" = 'root' ] && error "This Script must not be run as root!"
}

function checkSudoUser() {
	if [ -z "$SUDOUSER" ]; then
		echo -e "${BRed}Some parts of this script must not be run as root!${COff}"
		echo -e "${BRed}Please export an environment variable ${COff}SUDOUSER${BRed} and define an user who will run these parts!${COff}"
		error
	fi
}

function updateFile() {
	# check if files differ
	[ -n "`diff $1 $2`" ] && {
		sysMessage -n "Updating file $1..."
		cp -f $2 $1
		# recheck
		[ -z "`diff $1 $2`" ] && okMessage "OK" || error "Failed"
	}
}
