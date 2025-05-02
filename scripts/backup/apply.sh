#!/bin/bash

#
# > backup/apply.sh
#     Applies a backup of the AzerothCore database.
#       Meant to be run manually.
#
#     You can supply either a relative or absolute path.
#
#     Usage: ./scripts/backup/apply.sh [-a] <backup_path>
#
#          e.g. ./scripts/backup/apply.sh ./backups/2024/09/18/2024-09-18_09-48-59.tar
#          e.g. ./scripts/backup/apply.sh /home/aUser/Downloads/backup.tar
#


# SETUP

# Force the current directory to be the root directory
#   Repeated here since we can't source until we correct the working directory.
script_dir="$(dirname "$(readlink -fm "$0")")"
root_dir="$script_dir/../.."
cd "$root_dir"


# SOURCES

source "./scripts/src/log.sh"
source "./scripts/src/server.sh"

source "./scripts/backup/_config.sh"
source "./scripts/backup/_prep.sh"


# CONFIG

backup_dir="./backups"
abs_backup_dir="$(pwd)/$backup_dir"
backup_temp_dir="$backup_dir/.tmp"

overwrite_temp_backup_folder()
{
  log_info "Overwriting./.backup/!"
  rm -rf .backup
  mkdir -p .backup
  log_info "Overwritten ./.backup/."
}

unzip_backup()
{
  backup_path="$1"
  log_info "Unzipping the tar to ./.backup/"
  tar -xf "$backup_path" -C .backup
  log_info "Unzipped the tar to ./.backup/"
}

start_database_container()
{
  log_info "Starting the database container..."
  docker compose up -d ac-database
}

stop_database_container()
{
  log_info "Stopping the database container..."
  docker compose down
}




# FUNC

payload()
{
  log_info "Applying backup '$backup_path'..."
  cat .backup/acore_auth.sql | docker exec -i ac-database /usr/bin/mysql -u root --password=password acore_auth
  cat .backup/acore_characters.sql | docker exec -i ac-database /usr/bin/mysql -u root --password=password acore_characters
  cat .backup/acore_world.sql | docker exec -i ac-database /usr/bin/mysql -u root --password=password acore_world
  log_info "Hopefully applied '$backup_path'."
}

# Params:
#  $1: backup path
#    (e.g. '2024-09-17_12-04-46.tar', '2024/09/17/2024-09-17_12-04-46.tar', '/user/anUser/backups/backup.tar')
apply_backup()
{
  backup_path=$1
  log_info "backup_path: $backup_path"
  overwrite_temp_backup_folder
  unzip_backup "$backup_path"
  start_database_container
  sleep 5 
  payload
  stop_database_container
}

show_help()
{
  echo "Usage: $ ./scripts/backup/apply.sh <backup_path>"
}

# MAIN

# Params:
#  $1: backup path
#    (e.g. '2024-09-17_12-04-46.tar' or '2024/09/17/2024-09-17_12-04-46.tar')
main()
{
  # Assumes that we are running from the root directory (guaranteed by setup)
  filepath=$1
  apply_backup $filepath
#  restart_ac_if_requested $*
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
