#!/bin/bash

#
# > backup/prune.sh
#     Prunes the existing backups of the AzerothCore database.
#       Meant to be run either as a cron job or manually.
#
#     Policy:
#       + Attempting to limit core backup (1 - 8 weeks) to < 100 GB.
#       + Long-term backups (8+ weeks) will be pruned to one per week
#           and kept indefinitely. They must be manually deleted.
#       + Guesstimate is < 3 GB per backup.
#
#     Schedule:
#       1 week:
#         keep all (~21 GB)
#       2 - 4 weeks:
#         keep every other day (~36 GB)
#       5 - 8 weeks:
#         keep 2 per week (~24 GB)
#       8+ weeks:
#         keep 1 per week (~12 GB per month)
#

source "./scripts/backup/_config.sh"


# TODO
