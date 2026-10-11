# Student card: 6705140026

This folder is yours alone. Its data, row counts, defects and answers are different from
every classmate's. **Do not edit anything in this folder.** The grader ignores your copy
and uses the instructor's.

## Your names

| What | Name |
|---|---|
| Database | `reg_6705140026` |
| Round 3 account A | `s6705140026_alice`@`localhost` |
| Round 3 account B | `s6705140026_bob`@`localhost` |
| Round 4 accounts | `s6705140026_webapp`, `s6705140026_report`, `s6705140026_etl`, `s6705140026_kiosk`, `s6705140026_intern` |
| Bonus database | `perf_6705140026` |
| Every account you create starts with | `s6705140026_` |

## Your files

| File | Rows (excluding the header) | Note |
|---|---|---|
| `students.csv` | 41 | Contains **one** problem you meet in Round 1 |
| `courses.csv` | 8 | Clean |
| `enrollments.csv` | 45 | Contains **one** problem you meet in Round 2 |

Rule for the duplicate in `students.csv`: **the first occurrence in the file is the real
student.** Every later row with the same `student_id` is rejected.

## Round 3: the two rows you lock

| | `student_id` |
|---|---|
| Row X | `69185995` |
| Row Y | `69227924` |

`s6705140026_alice` and `s6705140026_bob` each get exactly `SELECT, UPDATE` on `reg_6705140026.students`.

## Round 4: the role spec

After `bad_grants.sql` and then your `fixes.sql` have run, every account must hold
**exactly** these privileges: nothing more, nothing less. Grant them directly to the
account (no roles).

| Account | Host | Privileges | State |
|---|---|---|---|
| `s6705140026_webapp` | localhost | SELECT, INSERT, UPDATE on reg_6705140026.* (all tables) | unlocked |
| `s6705140026_report` | localhost | SELECT on reg_6705140026.* (all tables) | unlocked |
| `s6705140026_etl` | localhost | INSERT on reg_6705140026.enrollments only | unlocked |
| `s6705140026_kiosk` | localhost | SELECT on reg_6705140026.students only | LOCKED |
| `s6705140026_intern` | - | must not exist | - |

No account whose name starts with `s6705140026_` may be left on host `%`.
