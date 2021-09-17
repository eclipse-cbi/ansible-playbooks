#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2021 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html
# SPDX-License-Identifier: EPL-2.0
#*******************************************************************************

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

if [ "${1:-}" == "--list" ] ; then
    jsonnet "${SCRIPT_FOLDER}/inventory.jsonnet" | jq '.inventory'
elif [ "${1:-}" == "--host" ]; then
    jq <<<'{"_meta": {"hostvars": {}}}'
else
    jq <<<'{}'
fi