# Student card: 6705140038

This folder is yours alone. Its data, row counts, defects and answers are different from
every classmate's. **Do not edit anything in this folder.** The grader ignores your copy
and uses the instructor's.

## Your names

| What | Name |
|---|---|
| Database | `reg_6705140038` |
| Round 3 account A | `s6705140038_alice`@`localhost` |
| Round 3 account B | `s6705140038_bob`@`localhost` |
| Round 4 accounts | `s6705140038_webapp`, `s6705140038_report`, `s6705140038_etl`, `s6705140038_kiosk`, `s6705140038_intern` |
| Bonus database | `perf_6705140038` |
| Every account you create starts with | `s6705140038_` |

## Your files

| File | Rows (excluding the header) | Note |
|---|---|---|
| `students.csv` | 34 | Contains **one** problem you meet in Round 1 |
| `courses.csv` | 8 | Clean |
| `enrollments.csv` | 47 | Contains **one** problem you meet in Round 2 |

Rule for the duplicate in `students.csv`: **the first occurrence in the file is the real
student.** Every later row with the same `student_id` is rejected.

## Round 3: the two rows you lock

| | `student_id` |
|---|---|
| Row X | `69130272` |
| Row Y | `69230977` |

`s6705140038_alice` and `s6705140038_bob` each get exactly `SELECT, UPDATE` on `reg_6705140038.students`.

## Round 4: the role spec

After `bad_grants.sql` and then your `fixes.sql` have run, every account must hold
**exactly** these privileges: nothing more, nothing less. Grant them directly to the
account (no roles).

| Account | Host | Privileges | State |
|---|---|---|---|
| `s6705140038_webapp` | localhost | SELECT, INSERT, UPDATE on reg_6705140038.* (all tables) | unlocked |
| `s6705140038_report` | localhost | SELECT on reg_6705140038.* (all tables) | unlocked |
| `s6705140038_etl` | localhost | INSERT on reg_6705140038.enrollments only | unlocked |
| `s6705140038_kiosk` | localhost | SELECT on reg_6705140038.students only | LOCKED |
| `s6705140038_intern` | - | must not exist | - |

No account whose name starts with `s6705140038_` may be left on host `%`.
