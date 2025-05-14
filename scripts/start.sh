#!/bin/bash

#
# > start.sh
#     Starts the AzerothCore server.
#       Internally, wraps `docker compose up` with a backup script.
#       Any flags passed to this script (notably -d) will be passed to `docker compose up`.
#         ...meaning that to start the server in detached mode, run `docker compose up -d`.
#


# SETUP

# Force the current directory to be the root directory.
#   Repeated here since we can't source until we correct the working directory.
script_dir="$(dirname "$(readlink -fm "$0")")"
root_dir="$script_dir/.."
cd "$root_dir"


# SOURCES

source "./scripts/src/cron.sh"
source "./scripts/src/log.sh"
source "./scripts/src/server.sh"


# MAIN

main()
{
    add_backup_cron_job
    if backup_cron_job_exists
    then
        log_info "Cron job successfully created!"
        start_ac $@
    else
        log_error "Failed to start - backup cron job could not be created."
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
