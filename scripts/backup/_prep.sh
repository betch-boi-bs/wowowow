#!/bin/bash

#
# > backup/_prep.sh
#     Functions for preparing for backup actions.
#

source "./scripts/src/log.sh"


# INTERFACE

# Params:
#   $1: AzerothCore directory
set_working_directory()
{
  directory="$1"
  if [ -n "$directory" ]
  then
    log_info "Setting working directory to $directory..."
    cd "$directory"
  fi
}

prepare_for_backup()
{
  log_info "Preparing for backup..."
  stop_ac
}
