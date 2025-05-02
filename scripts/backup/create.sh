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

get_backup_filename()
{
  echo "$(date "+%Y-%m-%d_%H-%M-%S").tar"
}

overwrite_temp_backup_folder()
{
  rm -rf .backup
  mkdir -p .backup
}

ensure_backups_directory_exists()
{
  mkdir -p backups
}

zip_to_backups_directory()
{
  ensure_backups_directory_exists
  tar -czvf "./backups/$(get_backup_filename)" -C .backup .
}


create_backup()
{
  log_info "Starting the database container..."
  docker compose up -d ac-database
  sleep 5 
  overwrite_temp_backup_folder
  log_info "Creating backup..."
  docker exec ac-database /usr/bin/mysqldump -u root --password=password acore_auth > .backup/acore_auth.sql
  docker exec ac-database /usr/bin/mysqldump -u root --password=password acore_world > .backup/acore_world.sql
  docker exec ac-database /usr/bin/mysqldump -u root --password=password acore_characters > .backup/acore_characters.sql
  zip_to_backups_directory
  log_info "Stopping the database container..."
  docker compose down
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
