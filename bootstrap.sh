#!/usr/bin/env bash
# bootstrap.sh: rebuild your whole lab server from the files in this repo.
#
# Run it INSIDE the container:      bash /work/bootstrap.sh
#
# Rules (the grader checks them):
#   * It must work on a brand-new empty server AND when run a second time.
#   * It must never write into /work. The grader mounts /work READ-ONLY.
#     Use /tmp or the server's own directories for temporary files.
#   * Exit with an error (non-zero) if any step fails. `set -euo pipefail` does that for you.
#
# You extend this file in Rounds 1, 2, 3 and 4. Replace each `todo` line with real commands.
set -euo pipefail

ID="$(head -n1 /work/student.txt | tr -d '[:space:]')"
if [[ ! "$ID" =~ ^[A-Za-z0-9]{1,20}$ ]]; then
  echo "bootstrap.sh: put your student ID on line 1 of student.txt" >&2; exit 1
fi
DB="reg_${ID}"
PACKET="/work/packets/${ID}"
if [[ ! -d "$PACKET" ]]; then
  echo "bootstrap.sh: no folder $PACKET. Check student.txt, then Sync fork and git pull." >&2; exit 1
fi

todo() { echo "bootstrap.sh: TODO not done yet: $*" >&2; exit 1; }

# --- Step 0 (given): root credentials for this container --------------------
# Written to /root, NOT to /work, so the password never lands in your public repo.
# After this, plain `mysql` and `mysqldump` log in as root with no -p.
cat > /root/.my.cnf <<'EOF'
[client]
user=root
password=RootPass123!
EOF
chmod 600 /root/.my.cnf

# --- Round 1 -----------------------------------------------------------------
# 1a. Drop the database $DB if it exists, then create it with utf8mb4.
todo "1a: drop and recreate the database"
# 1b. Copy students.csv, courses.csv and enrollments.csv from $PACKET into the directory
#     that `SELECT @@secure_file_priv;` names. (The server may only read files from there.)
todo "1b: copy the CSVs"
# 1c. Create the tables:   mysql "$DB" < /work/schema.sql
todo "1c: run schema.sql"
# 1d. Load the data:       mysql "$DB" < /work/load.sql
todo "1d: run load.sql"

# --- Round 3 -----------------------------------------------------------------
# Create s${ID}_alice and s${ID}_bob on localhost with exactly SELECT, UPDATE on $DB.students.
# Drop them first (DROP USER IF EXISTS) so that a second run still works.
# Uncomment the next line when you start Round 3, then replace it.
# todo "3: create alice and bob"

# --- Round 4 -----------------------------------------------------------------
# Run the instructor's bad_grants.sql, then your fixes.sql:
#   mysql < "$PACKET/bad_grants.sql"
#   mysql < /work/fixes.sql
# Uncomment the next line when you start Round 4, then replace it.
# todo "4: apply bad_grants.sql, then fixes.sql"

echo "bootstrap.sh: finished OK for $DB"
