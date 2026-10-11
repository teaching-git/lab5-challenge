#!/usr/bin/env bash
# baseline.sh: Round 5, step 1. Record what "healthy" looks like, before any incident.
#
# Run it INSIDE the container, right after a clean `bash /work/bootstrap.sh`:
#       bash /work/baseline.sh
# Then commit everything in baseline/ BEFORE you run any incident.
#
# Re-run it (and commit again) whenever you change bootstrap.sh, schema.sql, load.sql
# or fixes.sql. The grader checks that your baseline matches what bootstrap.sh builds.
set -euo pipefail

ID="$(head -n1 /work/student.txt | tr -d '[:space:]')"
DB="reg_${ID}"
OUT=/work/baseline
mkdir -p "$OUT"

todo() { echo "baseline.sh: TODO not done yet: $*" >&2; exit 1; }

# 1 (given). The database: a full logical dump of reg_<ID>.
mysqldump --single-transaction --routines --triggers "$DB" > "$OUT/reg.sql"

# 2. Row counts of every table in $DB  ->  $OUT/counts.txt
todo "2: row counts"

# 3. CHECKSUM TABLE for every table in $DB  ->  $OUT/checksums.txt
todo "3: checksums"

# 4. Every account whose name starts with s${ID}_ , as SQL that can recreate it
#    (SHOW CREATE USER + SHOW GRANTS)  ->  $OUT/accounts.sql
#    The README has a hint for this step.
todo "4: accounts"

echo "baseline.sh: baseline written to $OUT. Commit it now."
