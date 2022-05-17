#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "${SCRIPT_DIR}"

PYTHONPATH="${SCRIPT_DIR}:${PYTHONPATH}"
python ${SCRIPT_DIR}/exprev/cli/cli.py "${@:1}"
