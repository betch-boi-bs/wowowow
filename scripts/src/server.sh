#!/bin/bash

#
# > server.sh
#     Provides server start/stop functionality.
#


# SOURCES

source "./scripts/src/log.sh"


# INTERFACE

start_ac()
{
  log_info 'Starting the server...'
  docker compose up $@
}

stop_ac()
{
  log_info "Stopping the server..."
  docker compose down
}

restart_ac()
{
  log_info "Restarting the server..."
  stop_ac
  start_ac
}

# Params:
#   $*: pass all params so flag can be found
restart_ac_if_requested()
{
  if [[ $* == *--restart* ]]
  then
    restart_ac
  fi
}
