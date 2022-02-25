#!/bin/bash

set -e

# shellcheck disable=SC2046
project_root=$(dirname $(dirname $(realpath "$0")))
. "$project_root/bin/includes/functions.sh" "$project_root"
sampleDataInstall