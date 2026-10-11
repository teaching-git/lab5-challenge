# Student card: 6705142032

This folder is yours alone. Its data, row counts, defects and answers are different from
every classmate's. **Do not edit anything in this folder.** The grader ignores your copy
and uses the instructor's.

## Your names

| What | Name |
|---|---|
| Database | `reg_6705142032` |
| Round 3 account A | `s6705142032_alice`@`localhost` |
| Round 3 account B | `s6705142032_bob`@`localhost` |
| Round 4 accounts | `s6705142032_webapp`, `s6705142032_report`, `s6705142032_etl`, `s6705142032_kiosk`, `s6705142032_intern` |
| Bonus database | `perf_6705142032` |
| Every account you create starts with | `s6705142032_` |

## Your files

| File | Rows (excluding the header) | Note |
|---|---|---|
| `students.csv` | 37 | Contains **one** problem you meet in Round 1 |
| `courses.csv` | 8 | Clean |
| `enrollments.csv` | 43 | Contains **one** problem you meet in Round 2 |

Rule for the duplicate in `students.csv`: **the first occurrence in the file is the real
student.** Every later row with the same `student_id` is rejected.

## Round 3: the two rows you lock

| | `student_id` |
|---|---|
| Row X | `69190737` |
| Row Y | `69272388` |

`s6705142032_alice` and `s6705142032_bob` each get exactly `SELECT, UPDATE` on `reg_6705142032.students`.

## Round 4: the role spec

After `bad_grants.sql` and then your `fixes.sql` have run, every account must hold
**exactly** these privileges: nothing more, nothing less. Grant them directly to the
account (no roles).

| Account | Host | Privileges | State |
|---|---|---|---|
| `s6705142032_webapp` | localhost | SELECT, INSERT, UPDATE on reg_6705142032.* (all tables) | unlocked |
| `s6705142032_report` | localhost | SELECT on reg_6705142032.* (all tables) | unlocked |
| `s6705142032_etl` | localhost | INSERT on reg_6705142032.enrollments only | unlocked |
| `s6705142032_kiosk` | localhost | SELECT on reg_6705142032.students only | LOCKED |
| `s6705142032_intern` | - | must not exist | - |

No account whose name starts with `s6705142032_` may be left on host `%`.
