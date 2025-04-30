#!/bin/bash

#
# > backup/create.sh
#     Creates a backup of the AzerothCore database.
#       Meant to be run either as a cron job or manually.
#


# SETUP

# Force the current directory to be the root directory.
#   Repeated here since we can't source until we correct the working directory.
script_dir="$(dirname "$(readlink -fm "$0")")"
root_dir="$script_dir/../.."
cd "$root_dir"


# SOURCES

source "./scripts/src/log.sh"
source "./scripts/src/server.sh"

source "./scripts/backup/_config.sh"
source "./scripts/backup/_prep.sh"


# FUNC

get_backup_path()
{
  year=$(date "+%Y")
  month=$(date "+%m")
  date=$(date "+%d")
  path="$year/$month/$date"
  echo "$path"
}

get_backup_filename()
{
  echo "$(date "+%Y-%m-%d_%H-%M-%S").tar"
}

create_backup()
{
  path=$(get_backup_path)
  filename=$(get_backup_filename)
  log_info "Creating backup '$filename'..."
  # Docker will automatically create our backup directory when it's mounted if it doesn't exist
  docker run \
    --rm \
    --mount source=wowowow_ac-database,target=/var/lib/mysql \
    -v "$(pwd)/backups/$path":/backups \
    ubuntu bash -c "cd /var/lib/mysql && tar cvf /backups/$filename ." \
      > /dev/null
}


# MAIN

# Effects:
#   Stops AzerothCore while backing up.
# Flags:
#   --restart: request server restart after backup
main()
{
  # Assumes that we are running from the root directory (guaranteed by setup)
  prepare_for_backup
  create_backup
  restart_ac_if_requested $*
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
