#!/bin/bash

# leogtz

set -o pipefail
set -o errexit
set -o nounset

# readonly work_dir=$(dirname "$(readlink --canonicalize-existing "${0}")")

show_help() {
cat <<HELP_TEXT

    ${0} [OPTION...] PROCESS_NAME

$(echo -e "\033[1mOPTIONS\033[0m")
    -i, --ignore-case: Do not ignore case distinctions in patterns and input data.
    -h, --help Output a usage message and exit.

HELP_TEXT
}

process_list() {
    local -r process_name="${1}"
    local -r ignore="${2}"

    if [[ -z "${process_name}" ]]; then
        return 1
    fi
    if [[ -z "${ignore}" ]]; then
        return 1
    fi
    if ((ignore)); then
        ps -ef | grep --ignore-case "${process_name}"
    else
        ps -ef | grep "${process_name}"
    fi
}

kill_p() {
    local -r pid="${1}"
    if [[ -z "${pid}" ]]; then
        return 1
    fi

    kill -kill "${pid}"
}

kill_process() {
    local -r process_name="${1}"
    local -r ignore="${2}"
    local process
    local pid

    while read process; do
        pid=$(awk '{print $2}' <<< "${process}")
        if ! kill_p "${pid}"; then
            printf "Could not kill '%s' with %d pid\n" "${process_name}" "${pid}"
        else
            printf "%s [%d] killed\n" "${process_name}" "${pid}"
        fi
    done < <(process_list "${process_name}" "${ignore}" | grep --invert-match "gre[p]" | grep --invert-match "${0}")
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

for process in "${@}"; do
    kill_process "${process}" "${ignore_case_flag}"
done

exit 0
