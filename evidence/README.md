# evidence/

Create each file when you reach its round. The grader looks for these exact names.

| File | Round | What goes in it |
|---|---|---|
| `r0_setup.txt` | 0 | Output of `docker version`, `docker compose version` and `SELECT VERSION();` |
| `r2_defects.md` | 1–2 | One entry per planted defect: the CSV row, the error number, what you decided |
| `r3_prediction.md` | 3 | Your prediction, committed **before** you run anything |
| `r3_locking.txt` | 3 | Both errors, the lock-wait and processlist output, the deadlock section, three sentences |
| `audit.md` | 4 | One row per finding: what, why it is dangerous, the exact corrective statement |
| `incident_log.md` | 5 | Each change, its menu type, the comparison output that reveals it, the restore gap |
| `bonus_explain.txt` | Bonus | Both `EXPLAIN ANALYZE` outputs and your explanation |
