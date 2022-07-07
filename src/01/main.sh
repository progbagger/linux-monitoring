#!/bin/bash
# shellcheck disable=SC1091

source ./validate_input.sh

validate_input "$1" "$2" "$3" "$4" "$5" "$6" $#

exit_code=$?
exit $exit_code
