#!/bin/bash

SCRIPT="process"
while getopts e:s:c:p: flag
do
    case "${flag}" in
        s) SCRIPT="${OPTARG}";;
        c) CONFIG="${OPTARG}";;
        p) REPO_PATH="${OPTARG}";;
    esac
done

# Going to repo dir
if [ -z "$REPO_PATH" ]; then
    REPO_PATH="/polydoc" # change to the actual repo path
fi
cd $REPO_PATH

# Loading env vars
set -o allexport
source .env
set +o allexport

pip install -e .

echo "Start time: $(date)"

# Launch script
echo "Running: python -m polydoc $SCRIPT --config-file $CONFIG"
python -m polydoc $SCRIPT --config-file $CONFIG

echo "End time: $(date)"