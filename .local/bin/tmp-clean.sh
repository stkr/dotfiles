#! /bin/bash

TMP_CLEAN="${HOME}/.local/bin/tmp-clean"
if [[ -x "${TMP_CLEAN}" ]]; then
    export RUST_LOG=info

    export CLEAN_PATH="${HOME}/.tmp"
    export MAX_AGE=28
    echo "Cleaning files older than ${MAX_AGE} days from ${CLEAN_PATH}..."
    if [[ -d "${CLEAN_PATH}" ]]; then
        "${TMP_CLEAN}" -a "${MAX_AGE}" -d "${CLEAN_PATH}"
    else
        echo "ERROR: Directory [${CLEAN_PATH}] does not exist"
    fi
else
    echo "ERROR: No executable [${TMP_CLEAN}]"
fi
