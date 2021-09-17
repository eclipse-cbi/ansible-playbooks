#!/bin/bash

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

if [ $# -ne 2 ] ; then
  echo "Usage: ssh-add-passphrase keyfile passfile"
  exit 1
fi

expect << EOM
  spawn ssh-add $1
  expect "Enter passphrase"
  send $(perl -e 'print quotemeta shift(@ARGV)' "$(pass "${2}")")\r
  expect eof
EOM