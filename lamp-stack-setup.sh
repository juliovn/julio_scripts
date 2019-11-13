#!/bin/bash

# This script automates installation of the LAMP stack on a RPM machine

# Check if user is root
if [[ "${UID}" -eq 0 ]]; then
    echo "Please do not run the script as root." >&2
    exit 1
fi

# Default value for exit status
EXIT_STATUS=0

# Set variable for script name
SCRIPT_NAME="${0##*/}"

# Log file
LOG_FILE="/tmp/$SCRIPT_NAME.$(date '+%s')"

# Set timestamp
TIMESTAMP=$(date '+%F_%H:%M:%S')

# Log function
function log {
	local MESSAGE="${@}"

	if [[ "${VERBOSE}" = "true" ]]; then
		# Output message
		echo "${MESSAGE}"
	fi

	# Send message to LOG_FILE
	echo "${TIMESTAMP} || ${MESSAGE}" &>> ${LOG_FILE}

	# And finally send to syslog as well
	logger -t "${SCRIPT_NAME}" "${MESSAGE}"
}

# Log output of command
function logRun {
	# Command to run
	local CMD="${1} | tee -a ${LOG_FILE}"
	
	# Run command
	eval $CMD
}

function myExit {
	# Exit code
	local EXIT_CODE="${1}"
	shift

	# Exit signal ("continue", "exit", "break")
	local EXIT_SIGNAL="${1}"
	shift

	# Message
	local MESSAGE="${@}"

	if [[ "${EXIT_CODE}" -ne 0 ]]; then
		# Output error message
		log "${MESSAGE}"

		# Set EXIT_STATUS to EXIT_CODE
		EXIT_STATUS="${EXIT_CODE}"

		# Check exit signal and use appropriate exit
		case ${EXIT_SIGNAL} in
			"continue") continue ;;
			"break") break ;;
			"exit") exit ${EXIT_CODE} ;;
			*)
				echo "Invalid signal \"${EXIT_SIGNAL}\"" >&2
				echo "Please use 'continue', 'break', or 'exit'" >&2
				exit 1
				;;
		esac
	fi
}

function usage {
	echo >&2
	echo "Usage: ${SCRIPT_NAME} [-v]"
	echo >&2
	echo "This script is a bash script bootstrap skeleton" >&2
	echo >&2
	echo "	-v	Activate message output"
	echo >&2
	exit 1
}

# If no parameters are passed output usage
if [[ "${#}" -lt 1 ]]; then
    usage
fi

# Parse options
while getopts v OPTION
do
	case ${OPTION} in
		v) VERBOSE="true" ;;
		?) usage ;;
	esac
done

# Shift parameters
shift "$(( OPTIND -1 ))"

# Finish script
exit ${EXIT_STATUS}
