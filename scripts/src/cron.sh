#!/bin/bash

#
# > cron.sh
#     Handles cron interactions (primarily for setting up backups).
#
#   KNOWN BUGS:
#     - Uses the time to find and delete the command from cron instead of the command.
#         Changing the time requires manual deletion of the cron command.
#         Additionally, any cron tasks scheduled for the exact same time and schedule may be deleted.
#


# SOURCES

source "./scripts/src/log.sh"


# CONSTANTS

working_dir="$(pwd)"
cron_dump_fn='.CRON_DUMP'
backup_command="$(pwd)/scripts/backup/create.sh --restart"


# CONFIG

backup_time="20 04 * * *"


# FUNC

dump_crontab()
{
    crontab -l > "$cron_dump_fn"
}

flash_crontab_from_dump()
{
    crontab "$cron_dump_fn"
}

delete_crontab_dump()
{
    rm "$cron_dump_fn"
}

append_backup_task()
{
    if ! grep -q "$backup_command" "$cron_dump_fn"
    then
        echo "$backup_time $backup_command" >> "$cron_dump_fn"
    fi
}

delete_backup_task()
{
    sed -i "/$backup_time/d" "$cron_dump_fn"
}

# Params:
#   $1: callback to run once crontab dump has been created
update_crontab()
{
    callback=$1
    dump_crontab
    $callback
    flash_crontab_from_dump
    delete_crontab_dump
}


# INTERFACE

add_backup_cron_job()
{
    log_info "Creating backup cron job..."
    update_crontab append_backup_task
}

delete_backup_cron_job()
{
    log_info "Removing backup cron job..."
    update_crontab delete_backup_task
}

backup_cron_job_exists()
{
    dump_crontab
    if ! grep -q "$backup_time" "$cron_dump_fn"
    then
        delete_crontab_dump
        return 1
    else
        delete_crontab_dump
        return 0
    fi
}
