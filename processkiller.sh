#!/bin/bash

set -o pipefail
set -o errexit
set -o nounset

readonly work_dir=$(dirname "$(readlink --canonicalize-existing "${0}")")

show_help() {
cat <<HELP_TEXT

    ${0} [OPTION...] PROCESS_NAME

$(echo -e "\033[1mOPTIONS\033[0m")
    -i, --ignore-case: Do not ignore case distinctions in patterns and input data.
    -h, --help Output a usage message and exit.

HELP_TEXT
}

readonly opts=$(getopt -o ih --long ignore-case,help -- "${@}" 2> /dev/null)

eval set -- "${opts}"
ignore_case_flag=0
stlen_flag=0
count_flag=0

while true; do
    case "${1}" in

        --ignore-case|-i)
            ignore_case_flag=1
            shift
            shift
            ;;

        --help|-h)
            show_help
            exit 0
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            break
            ;;
    esac
done

echo "Ignore: ${ignore_case_flag}"
echo "Args -> [${@}]"

exit 0
