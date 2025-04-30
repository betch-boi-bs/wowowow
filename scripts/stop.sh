#!/bin/bash

#
# > stop.sh
#     Stops the AzerothCore server.
#       Internally, wraps `docker compose down` with a backup script.
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

source "./scripts/backup/_prep.sh"


# MAIN

main()
{
    delete_backup_cron_job
    if backup_cron_job_exists
    then
        log_error "Backup cron job could not be deleted."
    fi
    stop_ac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
