#!/bin/bash
# Shell bookmarks with bash completion

# Detect if sourced and exit if not.
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then printf '%s\n' "This script is designed to be sourced, not executed!"; exit 1; fi
# Set SHELLMARKS directory location if not already set from environment.
if [[ ! "${SHELLMARKS}" ]]; then export SHELLMARKS="${HOME}/.shellmarks"; fi
# Create SHELLMARKS directory if not exist.
if [[ ! -e "${SHELLMARKS}" ]]; then mkdir "${SHELLMARKS}"; fi

# Run completion at start
complete -W "$(/bin/ls -A "${SHELLMARKS}")" cdd

# Run cdd
cdd() {
  case $1 in
    -a|--add) if [[ "$2" ]]; then echo "${PWD}" > "${SHELLMARKS}"/"$2" && complete -W "$(/bin/ls -A "${SHELLMARKS}")" cdd; fi ;;
    -d|--delete) if [[ "$2" ]]; then rm "${SHELLMARKS}"/"$2"; fi ;;
    -l|--list) cd "${SHELLMARKS}" || return; grep ^ /dev/null ./* | column -t -s : ; cd - &>/dev/null || return ;;
    -f|--fzf) cd_fzf="$(/bin/ls -A "${SHELLMARKS}" | fzf --preview-window="down:15%" --preview="(cat ${SHELLMARKS}/{})")"; cd "$(cat "${SHELLMARKS}"/"${cd_fzf}")" || return ;;
    -h|--help)
      printf "cdd\n"
      printf "  bookmark    | change directory to bookmark\n"
      printf "  -a new_name | add bookmark from current directory\n"
      printf "  -d bookmark | delete bookmark by name\n"
      printf "  -l          | list all bookmarks and their paths\n"
      printf "  -f          | fzf\n"
    ;;
    --*|-*) printf '%s\n' "unknown option: $1" ;;
    *) if [[ ! "$1" ]]; then return 0; elif [[ -f "${SHELLMARKS}"/"$1" ]]; then cd "$(cat "${SHELLMARKS}"/"$1")" || return; fi ;;
  esac
}
