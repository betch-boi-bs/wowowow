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


# FUNC

# Params:
#   $1: backup path
_apply_backup()
{
  backup_path=$1
  log_info "Applying backup '$backup_path'..."
  docker run \
    --rm \
    --mount source=ac-database,target=/var/lib/mysql \
    -v "$abs_backup_dir":/backups \
    ubuntu bash -c "cd /var/lib/mysql && rm -rf * && tar xvf /$backup_path --strip 1" \
      > /dev/null
}

ensure_temp_dir_exists()
{
  log_info "Ensuring backup temp directory '$backup_temp_dir' exists..."
  mkdir -p $backup_temp_dir
}

get_temp_path()
{
  abs_path=$1
  filename=$(basename ${abs_path})
  echo "$backup_temp_dir/$filename"
}

# Params:
#  $1: absolute backup path
#    (e.g. '/home/example/2024-09-17_12-04-46.tar')
copy_to_temp_dir()
{
  abs_path=$1
  ensure_temp_dir_exists
  temp_path=$(get_temp_path $abs_path)
  log_info "Copying backup '$abs_path' to temp file '$temp_path'..."
  cp $abs_path $temp_path
}

delete_temp_dir()
{
  log_info "Deleting backup temp directory '$backup_temp_dir'..."
  rm -rf $backup_temp_dir
}

# Params:
#  $1: backup path
#    (e.g. '2024-09-17_12-04-46.tar', '2024/09/17/2024-09-17_12-04-46.tar', '/user/anUser/backups/backup.tar')
apply_backup()
{
  abs_path=$1
  copy_to_temp_dir $abs_path
  temp_path=$(get_temp_path $abs_path)
  _apply_backup $temp_path
  delete_temp_dir
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
  restart_ac_if_requested $*
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
