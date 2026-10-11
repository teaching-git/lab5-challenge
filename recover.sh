#!/usr/bin/env bash
# recover.sh: Round 5. Put the server back to the baseline after ANY incident that obeys
# the Round 5 rules, not just yours. After the deadline the grader runs this script against
# your own incident and against three classmates' incidents you have never seen.
#
# Run it INSIDE the container:      bash /work/recover.sh
#
# Rules (the grader checks them):
#   * It logs in as root through /root/.my.cnf only (written by bootstrap.sh).
#     Never put a password in this file.
#   * It reads /work/baseline/ and never writes into /work (mounted READ-ONLY when graded).
#   * Afterwards, reg_<ID> AND every s<ID>_ account must match the baseline exactly:
#     same tables, same table definitions, same rows, same accounts, same privileges.
#   * Restore the baseline as a whole. Do not try to undo specific changes.
set -euo pipefail

ID="$(head -n1 /work/student.txt | tr -d '[:space:]')"
DB="reg_${ID}"
BASE=/work/baseline

todo() { echo "recover.sh: TODO not done yet: $*" >&2; exit 1; }

# 1. The database. Make $DB match $BASE/reg.sql exactly.
#    Think: what happens to a table that the incident ADDED, if you only load the dump?
todo "1: restore the database"

# 2. The accounts. Remove every s${ID}_ account, including ones the incident created,
#    then recreate the baseline accounts from $BASE/accounts.sql.
todo "2: restore the accounts"

echo "recover.sh: $DB and the s${ID}_ accounts are back to the baseline"
