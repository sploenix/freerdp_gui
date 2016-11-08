
# load bash color definitions
source $BASEDIR/functions/sys_functions.sh

# handle exit codes for gui windows
exitCodeHandler() {
	echo "Choosing action based on EXITCODE $EXITCODE"

	case "$EXITCODE" in
		"0")
			infoMessage "Script exited successfully"
			;;
		"1")
			# goto previous dialog
			infoMessage "Switching back to previous dialog \"$BACKTARGET\""
			jumpto $BACKTARGET
			;;
		"2")
			# run command for action
			infoMessage "Continuing script"
			;;
		"252")
			# exit script
			exitScript "Exiting script"
			;;
		*)
			infoMessage "No action defined for EXITCODE $EXITCODE"
	esac
}

cleanGuiData() {
	# clean variables
	unset LIST_ELEMENTS
	unset W
	unset H
	unset WIDTH
	unset HEIGHT
	unset WINDOW_TITLE
	unset TEXT_MSG
	unset COLUMN_TITLE
	unset MSG
	unset INFO_MSG
	unset WARN_MSG
}
