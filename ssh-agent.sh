#!/bin/bash
#*******************************************************************************
# Copyright (c) 2021 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html
# SPDX-License-Identifier: EPL-2.0
#*******************************************************************************

# shellcheck disable=SC2030,SC2031
# it's fine to modify $rc in subshell as it's properly scoped

ssh-add -l &>/dev/null && rc=${?} || rc=${?}

if [[ "${rc}" == 2 ]]; then
  # Could not open a connection to your authentication agent.

  # Load stored agent connection info and try to use it (in a subshell to avoid polluting current one)
  if [[ -r "${HOME}/.ssh-agent" ]]; then
    (
      eval "$(cat "${HOME}/.ssh-agent")" &> /dev/null
      ssh-add -l &>/dev/null && rc=${?} || rc=${?}

      if [[ "${rc}" == 2 ]]; then
        # Start agent and store agent connection info
        (umask 066; ssh-agent > "${HOME}/.ssh-agent")
      fi
    )
    #  Print ssh-agent info to stdout
    cat "${HOME}/.ssh-agent"
  fi
elif [[ "${rc}" != 0 ]] && [[ "${rc}" != 1 ]]; then # rc=1 when agent has no identities
  >&2 printf "Error while trying to list current ssh keys from ssh-agent\n"
  exit "${rc}"
fi
