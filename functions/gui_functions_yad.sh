
source $BASEDIR/functions/gui_functions_base.sh

# default buttons
# use GTK buttons (with icons)
# define default return values for buttons
BUTTON_BACK="gtk-media-previous:1"
BUTTON_OK="gtk-ok:2"
BUTTON_CONNECT="gtk-connect:2"
BUTTON_EXIT="gtk-quit:252"

selectComputerGroup() {
	echo "Opening computer group selection dialog"

	# unset variables
	unset CHECKLIST_DATA
	unset COMPUTER_GROUP

	LIST_ELEMENTS+=("TRUE" "$NAME_PC_STUD")
	LIST_ELEMENTS+=("FALSE" "$NAME_PC_WORKER")
	LIST_ELEMENTS+=("FALSE" "$NAME_PC_SERVER")
	LIST_ELEMENTS+=("FALSE" "$NAME_PC_NETWORK")
	LIST_ELEMENTS+=("FALSE" "$NAME_PC_SINGLE")

#	local WINDOW_TITLE="Gruppe von Rechnern auswählen"
	TEXT_MSG="Bitte eine Gruppe von Rechnern auswählen"
	COLUMN_TITLE="Rechnergruppe"
	WIDTH="400"
	HEIGHT="300"

	radioListWindow

	COMPUTER_GROUP=`echo $CHECKLIST_DATA | cut -d'|' -f2`

	echo "Selected computer group $COMPUTER_GROUP"
}

showInfoWindow() {
	echo "Opening info window"

	# handle custom window size
	customDim

	# open gui window
	yad --info \
		$W$WIDTH $H$HEIGHT \
		--scroll \
		--title="Info" \
		--text="$INFO_MSG" \
		--button $BUTTON_BACK \
		--button $BUTTON_OK > /dev/null 2>&1

	# get exit code from gui
	EXITCODE=$?

	# clean GUI data
	cleanGuiData

	# next action based on gui data
	exitCodeHandler
}

showWarnWindow() {
	echo "Opening warn window"

	# handle custom window size
	customDim

	yad --title="Warning" \
		$W$WIDTH $H$HEIGHT \
		--image=dialog-warn \
		--text="$WARN_MSG" \
		--button $BUTTON_BACK > /dev/null 2>&1

	# get exit code from gui
	EXITCODE=$?

	# clean GUI data
	cleanGuiData

	# next action based on gui data
	exitCodeHandler
}

requestUserPW() {
	echo "Opening user/pw entry window"

	# handle custom window size
	customDim

	AUTH_DATA=$(yad --title="$WINDOW_TITLE" \
		$W$WIDTH $H$HEIGHT \
		--image=utilities-terminal \
		--text="$MSG" \
		--form \
		--field="Benutzername:TEXT" "$DEFAULT_USER" \
		--field="Passwort:H" \
		--button $BUTTON_CONNECT) > /dev/null 2>&1

	# get exit code from gui
	EXITCODE=$?

	# clean GUI data
	cleanGuiData

	# next action based on gui data
	exitCodeHandler
}

requestPW() {
	echo "Opening user/pw entry window"

	# handle custom window size
	customDim

	AUTH_DATA=$(yad --title="$WINDOW_TITLE" \
		$W$WIDTH $H$HEIGHT \
		--image=utilities-terminal \
		--text="$MSG" \
		--form \
		--field="Passwort:H" \
		--button $BUTTON_CONNECT) > /dev/null 2>&1

	# get exit code from gui
	EXITCODE=$?

	# clean GUI data
	cleanGuiData

	# next action based on gui data
	exitCodeHandler
}

checkListWindow() {
	TYPE="--checklist"
	listWindow
}

radioListWindow() {
	TYPE="--radiolist"
	listWindow
}

listWindow() {
	echo "Opening checkListWindow"

	# handle custom window size
	customDim

	# open checklist dialog
	CHECKLIST_DATA=$(yad --list $TYPE \
		$W$WIDTH $H$HEIGHT \
		--title="$WINDOW_TITLE" \
		--text="\n$TEXT_MSG\n" \
		--column " " \
		--column "$COLUMN_TITLE" \
		"${LIST_ELEMENTS[@]}" \
		--button $BUTTON_BACK \
		--button $BUTTON_OK) > /dev/null 2>&1

	# get exit code from gui
	EXITCODE=$?

	# clean GUI data
	cleanGuiData

	# next action based on gui data
	exitCodeHandler
}

customDim() {
	if [ -n "$WIDTH" ]; then
		W="--width="
	fi
	if [ -n "$HEIGHT" ]; then
		H="--height="
	fi
}
