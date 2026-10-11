# Lab 5 Challenge: The Registrar's Database

You run a MySQL 8.4 server for a university registrar, on your own machine, inside Docker.
You build the database from code, make it relational, watch the server protect your data
under concurrent writes, lock down a messy set of accounts, and then break your own server
on purpose and write a script that repairs it.

| | |
|---|---|
| **Work** | Individual |
| **Marks** | 20 + 2 bonus |
| **Time** | about 3 hours of work, spread over the week |
| **Round 0 (setup) due** | **(set by make_packets.py)** (no marks, but required) |
| **Final deadline** | **(set by make_packets.py)**. Whatever is on your fork's default branch at that moment is your submission. |

## Contents

- [How this works](#how-this-works)
- [Round 0: setup](#round-0-setup)
- [Everyday commands](#everyday-commands)
- [Round 1: the repo is the server](#round-1-the-repo-is-the-server-4-marks)
- [Round 2: make it relational](#round-2-make-it-relational-5-marks)
- [Round 3: ACID, live](#round-3-acid-live-4-marks)
- [Round 4: least privilege to a spec](#round-4-least-privilege-to-a-spec-4-marks)
- [Round 5: break it, then recover from anything](#round-5-break-it-then-recover-from-anything-3-marks)
- [Bonus: indexes and EXPLAIN](#bonus-indexes-and-explain-2-marks)
- [How you are graded](#how-you-are-graded)
- [Before the deadline](#before-the-deadline)
- [Troubleshooting](#troubleshooting)

---

## How this works

1. You **fork** this repository on GitHub. Your fork is yours: you push to it, and it is your submission.
2. Your folder `packets/<your student ID>/` holds **your own data**: different rows, different
   defects, different answers from every classmate. Copying someone else's work gives the
   wrong names, counts and answers, and the grader compares everything against your packet.
3. MySQL runs in a Docker container. Your repo folder appears inside the container at `/work`.
   You edit files on your own machine with any editor; the container sees the changes at once.
4. **git runs on your machine, never inside the container.** All database commands run
   inside the container.

```
your machine                                 container "db" (MySQL 8.4)
┌──────────────────────────────┐            ┌────────────────────────────────┐
│ lab5-challenge/  (your fork) │  mounted   │ /work  = the same folder       │
│   edit files, git commit,    │ ─────────► │ bash, mysql, mysqldump         │
│   git push                   │            │ data lives in a Docker volume  │
└──────────────────────────────┘            └────────────────────────────────┘
```

Your fork is **public**: anyone can read it. Never commit a password other than the
lab passwords already written in this repo, and never commit a GitHub token.

---

## Round 0: setup

**Due (set by make_packets.py).**

### 0.1 Install Docker

Docker's own pages are the source of truth for requirements, because they change.
Check them before you install.

<details>
<summary><b>Windows 10 / 11</b></summary>

1. **Check your machine** against Docker's requirements:
   <https://docs.docker.com/desktop/setup/install/windows-install/>.
   You need 64-bit Windows with a recent build, 8 GB of RAM is recommended, and
   **hardware virtualisation must be enabled**. To check: open Task Manager →
   Performance → CPU, and look for **Virtualization: Enabled**. If it says Disabled,
   enable Intel VT-x or AMD-V (sometimes called SVM) in your BIOS/UEFI settings.
2. **Install or update WSL 2.** Open **PowerShell as Administrator** and run:
   ```powershell
   wsl --install
   ```
   If WSL is already installed, run `wsl --update` instead. Restart when asked.
3. **Download Docker Desktop for Windows** from the page in step 1 and run the installer.
   Leave **"Use WSL 2 instead of Hyper-V"** ticked. When it finishes, sign out or restart
   if it asks you to.
4. **Start Docker Desktop** from the Start menu. Accept the agreement (signing in is optional).
   Wait until the bottom-left corner says the engine is **running**.
5. **Install Git for Windows**: <https://git-scm.com/downloads/win>. The default options are
   fine. It includes Git Credential Manager, which signs you in to GitHub through your
   browser the first time you push.
6. **Check**, in a new PowerShell window:
   ```powershell
   docker version
   docker compose version
   docker run --rm hello-world
   git --version
   ```
   `hello-world` should print "Hello from Docker!".

Use **PowerShell** or **Windows Terminal** for every command in this README.
</details>

<details>
<summary><b>macOS</b></summary>

1. **Check your machine** against Docker's requirements:
   <https://docs.docker.com/desktop/setup/install/mac-install/>.
   Docker supports the current macOS and the two previous major versions.
2. **Find your chip**: Apple menu → About This Mac → **Chip**. "Apple M…" means Apple
   silicon; "Intel" means Intel. Download the matching Docker Desktop from the page above.
   The wrong one will not start.
3. Open `Docker.dmg` and drag **Docker** into **Applications**. Start Docker from
   Applications and accept the agreement (signing in is optional). Wait until the whale
   icon in the menu bar says Docker is running.
4. **Install git**: run `xcode-select --install` in Terminal (if git is already installed,
   it says so).
5. **Sign in to GitHub for git**: install the GitHub CLI (<https://cli.github.com>, or
   `brew install gh`), then run `gh auth login`, choose **GitHub.com → HTTPS → Login with a
   web browser**. It configures git for you.
6. **Check**, in Terminal:
   ```bash
   docker version
   docker compose version
   docker run --rm hello-world
   git --version
   ```
</details>

<details>
<summary><b>Linux</b></summary>

1. Install **Docker Engine** and the **Compose plugin** for your distribution:
   <https://docs.docker.com/engine/install/>.
2. Let your user run Docker without sudo, then log out and back in:
   ```bash
   sudo usermod -aG docker "$USER"
   ```
3. Install git and the GitHub CLI from your package manager, then run `gh auth login`
   (GitHub.com → HTTPS → Login with a web browser).
4. Check: `docker version`, `docker compose version`, `docker run --rm hello-world`.

Files that the container creates in your repo (logs, baseline) are owned by root.
If you cannot edit them, run `sudo chown -R "$USER" .` in the repo folder.
</details>

<details>
<summary><b>My computer cannot run Docker</b> (GitHub Codespaces)</summary>

If your laptop is too old, has virtualisation locked, or is managed by someone else, use
**GitHub Codespaces**: the same setup, in your browser.

1. Do step 0.2 (fork) first.
2. On **your fork's** page: **Code → Codespaces → Create codespace on main**.
3. Wait for the terminal to open. The database starts by itself; if it did not, run
   `docker compose up -d --wait`.
4. Everything else in this README works the same. git is already signed in.

A free GitHub account includes a monthly Codespaces allowance (120 core-hours, which is
about 60 hours on the default 2-core machine). That is far more than this lab needs, but
**stop the codespace when you finish working** (Code → Codespaces → ⋯ → Stop codespace).
</details>

Docker Desktop is free for personal and educational use.

### 0.2 Fork, then clone YOUR fork

1. Sign in to GitHub and open <https://github.com/YOUR-GITHUB-USERNAME/lab5-challenge>.
2. Click **Fork** → **Create fork**. You now have `https://github.com/<YOUR-USERNAME>/lab5-challenge`.
3. Clone **your fork**, not the instructor's repo:
   ```bash
   git clone https://github.com/<YOUR-USERNAME>/lab5-challenge.git
   cd lab5-challenge
   git remote add upstream https://github.com/YOUR-GITHUB-USERNAME/lab5-challenge.git
   git config user.name  "Your Name"
   git config user.email "the-email-on-your-github-account@example.com"
   git remote -v
   ```
   In the `git remote -v` output, **`origin` must show YOUR username.** If it shows the
   instructor's name, you cloned the wrong repo: see [Troubleshooting](#troubleshooting).

### 0.3 Start the server

From the repo folder, on your machine:

```bash
docker compose up -d --wait
docker compose exec db mysql -uroot -p -e "SELECT VERSION();"
```

The first `up` downloads the MySQL image (a few hundred MB). The password is `RootPass123!`.
You should see a version starting with `8.4`.

### 0.4 Prove it, and push

1. Edit `student.txt`: line 1 = your student ID exactly as on the class roster, line 2 = your name.
2. Check that `packets/<your ID>/` exists. If it does not, tell the instructor now.
3. Create `evidence/r0_setup.txt` containing the output of these three commands
   (copy and paste from the terminal is fine):
   ```bash
   docker version
   docker compose version
   docker compose exec db mysql -uroot -p -e "SELECT VERSION();"
   ```
4. Commit and push:
   ```bash
   git add student.txt evidence/r0_setup.txt
   git commit -m "Round 0: setup"
   git push
   ```
5. Open your fork on GitHub and check that both files are there.

**Push Round 0 by (set by make_packets.py).** If anything fails, you then still have days to get help.

---

## Everyday commands

**On your machine**, in the repo folder:

| Task | Command |
|---|---|
| Start the server | `docker compose up -d --wait` |
| Open a shell inside the container | `docker compose exec db bash` |
| Stop the server (data is kept) | `docker compose stop` |
| Delete the server **and all its data** | `docker compose down -v` |
| Save your work | `git add -A && git commit -m "..." && git push` |

**Inside the container** (after `docker compose exec db bash`):

| Task | Command |
|---|---|
| Your ID as a shell variable (do this first in every shell) | `ID=$(head -n1 /work/student.txt); echo $ID` |
| Rebuild everything from your repo | `bash /work/bootstrap.sh` |
| MySQL as root (after bootstrap has run once in this container) | `mysql` |
| MySQL as root (before bootstrap) | `mysql -uroot -p` |
| Leave the container shell | `exit` |

`bootstrap.sh` writes root's password into `/root/.my.cnf` **inside the container**, not
into your repo. If the container is recreated (for example after `docker compose down`),
that file is gone: run `bootstrap.sh` again, or use `mysql -uroot -p`.

**Never type `-pRootPass123!` with the password attached.** Your logs are committed to a
public repo, and the password would end up in them. Use `-p` alone and type it at the prompt.

Commit at the end of every round. Push as often as you like.

---

## The naming contract

In Round 5, classmates' incident scripts run against **your** database, and yours against
theirs. That only works if everyone uses the same names, so these are fixed:

- Database `reg_<ID>`. Tables `students`, `courses`, `enrollments`.
- **Every CSV header is a column with exactly that name**, in the table with the same name
  as the CSV file.
- You may add columns (a surrogate `id`, a timestamp). Each added column must be **nullable
  or have a DEFAULT**, so that an `INSERT` naming only the CSV columns works.
- Foreign keys: `fk_enr_student` on `enrollments(student_id)` → `students(student_id)`, and
  `fk_enr_course` on `enrollments(course_code)` → `courses(course_code)`.
- Every table: `ENGINE=InnoDB`, `DEFAULT CHARSET=utf8mb4`, and a `PRIMARY KEY`.
- Every account you create is named `s<ID>_something`.

Everything else (column types, keys, constraints, extra indexes) is your design.

---

## Round 1: the repo is the server (4 marks)

**Goal:** `docker compose down -v` destroys everything, and one command rebuilds it exactly.
The repo, not your laptop, is the source of truth.

1. Read `packets/<ID>/STUDENT_CARD.md` and look at the three CSVs.
2. Write `schema.sql` with `students` and `courses` (enrollments comes in Round 2).
   Follow the naming contract. No `CREATE DATABASE` or `USE` in this file:
   `bootstrap.sh` runs it inside `reg_<ID>`.
3. Find where the server is allowed to read files:
   ```sql
   SELECT @@secure_file_priv;
   ```
4. Write `load.sql` with `LOAD DATA INFILE` statements for `students.csv` and `courses.csv`
   from that directory. Read the MySQL manual page for `LOAD DATA`: you need the field and
   line terminators, and to skip the header line.
5. Fill in the Round 1 `todo` lines in `bootstrap.sh`.
6. **`students.csv` contains one planted problem.** When you load it, the server refuses a
   row. Read the error. Your card states the rule: **the first occurrence of a `student_id`
   in the file is the real student; later duplicates are rejected.** Make `load.sql` follow
   that rule, so loading never fails. Start `evidence/r2_defects.md` with this defect: the
   CSV row, the error number you saw, and what you decided.
7. **Checkpoint.** On your machine:
   ```bash
   docker compose down -v
   docker compose up -d --wait
   docker compose exec db bash /work/bootstrap.sh
   docker compose exec db bash /work/bootstrap.sh
   ```
   Both runs must end with `bootstrap.sh: finished OK`. Then check the row counts inside
   the container: `mysql -e "SELECT COUNT(*) FROM reg_$ID.students"` (and courses).
8. Commit: `schema.sql`, `load.sql`, `bootstrap.sh`, `evidence/r2_defects.md`.

---

## Round 2: make it relational (5 marks)

1. Add `enrollments` to `schema.sql`, with **both** foreign keys named as in the contract.
2. Load `enrollments.csv` in `load.sql`. **It contains one planted problem:** an enrolment
   for a student who does not exist, which the foreign key rejects. Pick either method:
   - **A (recommended).** Load the CSV into a staging table without constraints (a
     `TEMPORARY` table vanishes by itself at the end of the session), find the bad row with
     an anti-join (`LEFT JOIN … WHERE … IS NULL`), and copy only the good rows into
     `enrollments`.
   - **B.** `LOAD DATA … IGNORE` and read `SHOW WARNINGS`. Check afterwards that exactly the
     bad row is missing. If the server did not skip it, use method A.
3. Add the second defect to `evidence/r2_defects.md`: the CSV row, the error number, the decision.
4. **See the constraint refuse a write.** Inside `mysql`, try both of these and read the errors:
   - insert an enrolment for a `student_id` that does not exist;
   - delete a student who has enrolments.

   Declaring a constraint is not the same as seeing the engine refuse the write.
   (The grader runs the same two probes against your rebuilt database.)
5. Write the three queries in `queries/`. Each file holds **exactly one SELECT**, with the
   output columns and `ORDER BY` given in the file's header comment.

   | File | Question |
   |---|---|
   | `q1_no_enrolments.sql` | Which students have no enrolments? (needs a `LEFT JOIN`) |
   | `q2_avg_gpa.sql` | What is the average GPA of the students in each course? |
   | `q3_over_capacity.sql` | Which courses have more enrolments than their capacity? |

   Run each one: `mysql reg_$ID < /work/queries/q1_no_enrolments.sql`. All three return
   rows for every packet.
6. Re-run the Round 1 checkpoint (`down -v`, `up`, bootstrap twice). Commit.

---

## Round 3: ACID, live (4 marks)

You need **three terminals**. In each one, on your machine, open a container shell
(`docker compose exec db bash`) and run `ID=$(head -n1 /work/student.txt)`.

| Terminal | Who | Start it with |
|---|---|---|
| **A** | `s<ID>_alice` | `mysql --tee=/work/logs/r3_alice.log --prompt='\R:\m:\s alice> ' -u s${ID}_alice -p reg_$ID` |
| **B** | `s<ID>_bob` | `mysql --tee=/work/logs/r3_bob.log --prompt='\R:\m:\s bob> ' -u s${ID}_bob -p reg_$ID` |
| **R** | root | `mysql --tee=/work/logs/r3_root.log --prompt='\R:\m:\s root> '` |

`--tee` copies everything you see into a log file in your repo. The prompt shows the time,
so the logs show the order in which things happened.

**Before you start:**

1. Add the Round 3 step to `bootstrap.sh`: create `s<ID>_alice` and `s<ID>_bob` on
   `localhost`, with exactly `SELECT, UPDATE` on `reg_<ID>.students`. Re-run bootstrap.
2. **Predict first.** Write `evidence/r3_prediction.md`: for experiment 1 and for
   experiment 2 below, which terminal will get an error, which error, and why.
   **Commit and push it before you run anything.** The grader checks that the prediction
   was committed in an earlier commit than your results. It is marked for being on time,
   not for being right.
3. In terminal B: `SELECT @@innodb_lock_wait_timeout;` should return `10`.

**Experiment 1: lock wait.** Use rows X and Y from your card.

| Step | Terminal | Do |
|---|---|---|
| 1 | A | `START TRANSACTION;` then `UPDATE students SET gpa = 4.00 WHERE student_id = '<X>';`. Do **not** commit. |
| 2 | B | The same `UPDATE`. It hangs: B is waiting for A's lock. |
| 3 | R | Quickly, while B waits: `SELECT * FROM sys.innodb_lock_waits\G` and `SHOW PROCESSLIST;` |
| 4 | B | After 10 seconds B gets an error. Note its number. |
| 5 | A | `ROLLBACK;` |

**Experiment 2: deadlock.** Do steps 1–4 within 10 seconds, or the lock-wait timeout fires first.

| Step | Terminal | Do |
|---|---|---|
| 1 | A | `START TRANSACTION;` then update row **X** |
| 2 | B | `START TRANSACTION;` then update row **Y** |
| 3 | A | update row **Y**. A hangs. |
| 4 | B | update row **X**. One terminal gets an error immediately. Note which, and its number. |
| 5 | R | `SHOW ENGINE INNODB STATUS\G` and find the **LATEST DETECTED DEADLOCK** section |
| 6 | A and B | `ROLLBACK;` in both, then `exit` |

**Deliverable:** `evidence/r3_locking.txt` with:
- both error lines, exactly as printed;
- the `sys.innodb_lock_waits` row and the `SHOW PROCESSLIST` output from experiment 1;
- the whole LATEST DETECTED DEADLOCK section from experiment 2;
- **three sentences**: why the server made B wait or rolled one transaction back instead of
  letting both writes through, and whose changes survived.

Commit `evidence/r3_locking.txt` and the three logs in `logs/` (in a later commit than the prediction).

---

## Round 4: least privilege to a spec (4 marks)

`packets/<ID>/bad_grants.sql` creates the accounts "the previous admin" left behind. Some
are dangerous, and some just have more than they need.

1. Add the Round 4 step to `bootstrap.sh`: run `bad_grants.sql`, then your `fixes.sql`
   (start with an empty `fixes.sql`). Re-run bootstrap.
2. **Audit.**
   ```sql
   SELECT user, host, plugin, authentication_string = '' AS empty_password, account_locked
     FROM mysql.user ORDER BY user, host;
   SHOW GRANTS FOR 's<ID>_webapp'@'%';      -- and so on, for every account
   ```
3. Write `evidence/audit.md`: a table with one row per finding. Each row has three parts:
   **what** is wrong, **why** it is dangerous (one sentence), and the **exact statement**
   that fixes it.
4. Write `fixes.sql` so that every account matches the **role spec** in your card:
   **exactly** those privileges, nothing more and nothing less.
   - Allowed statements: `DROP USER`, `REVOKE`, `GRANT`, `ALTER USER`, `RENAME USER`.
   - Writing to any `mysql.*` table directly (`DELETE FROM mysql.user` and the like) scores
     **0 for the whole spec check**. Those tables are the server's internal storage; the
     statements above are the supported interface.
   - Dropping everything is not least privilege. Accounts the spec keeps must still exist.
5. Re-run bootstrap and audit again. Every account should now match the spec.
6. **Unmarked, but think about it:** one more account exists that `bad_grants.sql` did not
   create: `root@'%'`, made by the Docker image itself. Say in `audit.md` why it matters
   less here than on a real server (look at `docker-compose.yml`: is any port published?).
   **Do not change it**: the grader needs root.
7. Commit `fixes.sql`, `bootstrap.sh`, `evidence/audit.md`.

---

## Round 5: break it, then recover from anything (3 marks)

### 5.1 Baseline

1. Rebuild cleanly: `bash /work/bootstrap.sh`.
2. Complete `baseline.sh` and run it. It writes `baseline/reg.sql` (given), row counts,
   `CHECKSUM TABLE` results, and `baseline/accounts.sql`.

   **Hint for accounts.sql.** List your accounts, then for each one print a statement that
   recreates it, ending every line with `;`:
   ```bash
   mysql -N -e "SELECT CONCAT(QUOTE(user),'@',QUOTE(host)) FROM mysql.user
                WHERE user LIKE 's${ID}\_%' ORDER BY user, host" |
   while read -r acct; do
     mysql -N -e "SET SESSION print_identified_with_as_hex = ON; SHOW CREATE USER $acct; SHOW GRANTS FOR $acct;" </dev/null
   done | sed 's/$/;/' > /work/baseline/accounts.sql
   ```
   `</dev/null` stops the inner `mysql` from swallowing the list the loop is reading.
   Open the result and make sure you understand every line.
3. **Commit `baseline/` before you go on.** If you change bootstrap, schema, load or fixes
   later, rebuild, re-run `baseline.sh` and commit again. The grader checks that your
   baseline matches what your `bootstrap.sh` builds.

### 5.2 Design your incident

Write `incident.sql`. It makes **2 or 3 changes**, from **at least two different types** on this menu:

| Type | Example of the idea |
|---|---|
| Silent value change | change some values; row counts stay the same |
| Row deletion | delete some rows |
| Injected rows | insert fake rows |
| Structural change | drop an index or a column, or add an extra table |
| FK tampering | drop a foreign key by its contract name, then insert orphans |
| Privilege tampering | a backdoor `s<ID>_` account, or an extra grant to an existing one |

**Rules.** The grader checks every one of them.

- At least one change is **invisible to row counts**.
- At least one change is **not undone by loading the single-database dump** back over the
  damaged database.
- Touch only `reg_<ID>` and accounts whose names start with `s<ID>_`. Never touch root,
  never write to `mysql.*` tables, never touch other databases, never change server
  settings (`SET GLOBAL`, `SET PERSIST`) and never stop the server.
- Plain SQL only: no client commands (`system`, `\!`, `source`, `\.`, `tee`), no
  `INTO OUTFILE`, no `LOAD DATA`, no triggers, procedures, views or events.
- **Do not hard-code existing data values.** Pick your targets with a query
  (`… ORDER BY student_id LIMIT 2`, `WHERE gpa > 3.5`), so the incident also works on a
  classmate's data. Invented values for rows you insert are fine.
- Write `reg_<ID>` and `s<ID>_` literally, with your own ID. The grader rewrites them when
  it runs your incident on a classmate's server.
- It runs without any error on a freshly bootstrapped server.
- Its effect must differ from `examples/incident_example.sql` (study that example first).

### 5.3 Run it, find the damage, explain it

```bash
mysql reg_$ID < /work/incident.sql
```

(The grader also runs it with `reg_<ID>` as the default database. To practise first, the worked
example: `sed "s/0000000/$ID/g" /work/examples/incident_example.sql | mysql reg_$ID`.)

Compare the server with your baseline: row counts, checksums, `SHOW CREATE TABLE`, the
account list and grants. Write `evidence/incident_log.md`:

- each change, and its menu type;
- the comparison output that reveals it (paste it);
- which change loading the single-database dump would **not** undo, and why.

### 5.4 Recover as code

Complete `recover.sh`. After running it, `reg_<ID>` **and** every `s<ID>_` account must match
the baseline exactly. Test it: run your incident, run `bash /work/recover.sh`, compare with the
baseline again. Then test it against the example incident too.

After the deadline the grader runs your `recover.sh` against your own incident **and against
three classmates' incidents that you have never seen**. A script that only undoes your own
changes will fail. Restore the baseline as a whole.

Commit `incident.sql`, `baseline.sh`, `recover.sh`, `evidence/incident_log.md`.

> **The two lessons of this round.** A single-database dump contains no accounts and no
> grants, so restoring it cannot remove a backdoor. And loading a dump over an existing
> database leaves behind any table the dump does not mention. "Restored" means "matches the
> baseline", not "the restore command ran".

---

## Bonus: indexes and EXPLAIN (2 marks)

Keep this out of `bootstrap.sh` and out of `baseline/`.

1. In `bonus.sql`: create database `perf_<ID>` and a table `access_log` (for example
   `id`, `user_id`, `path`, `status`, `ts`), then fill it with **100,000 rows** using a
   recursive CTE inside an `INSERT … SELECT`. First run:
   ```sql
   SET SESSION cte_max_recursion_depth = 100000;
   ```
   Without it the CTE stops at 1,000 rows with error 3636.
2. Pick a filter on a column **without** an index that matches **very few** rows (well under
   1%; with many matches, the optimizer may rightly ignore an index). Run
   `EXPLAIN ANALYZE SELECT …` and save the output.
3. Add an index on that column. Run the same `EXPLAIN ANALYZE` again.
4. `evidence/bonus_explain.txt`: both outputs, and a short explanation of why the same
   experiment on `enrollments.student_id` would show no change. (Hint: what does InnoDB do
   when you declare a foreign key?)

---

## How you are graded

The grader clones your fork at the deadline and rebuilds everything in a clean container,
using the instructor's copy of your packet and of `docker-compose.yml`.

| Round | What is checked | Marks |
|---|---|---|
| 1 | `bootstrap.sh` completes on a clean server, and again on a second run | 2 |
| 1 | Row counts are correct for your packet | 1 |
| 1 | Every table: InnoDB, utf8mb4, primary key | 1 |
| 2 | The grader inserts an orphan enrolment (must fail with 1452) and deletes a referenced student (must fail with 1451) | 1 |
| 2 | `r2_defects.md` names both planted rows of your packet | 1 |
| 2 | q1, q2, q3 return the right rows for your packet (1 each) | 3 |
| 3 | `r3_prediction.md` committed before `r3_locking.txt` | 1 |
| 3 | Error 1205, the lock-wait output and both accounts in the processlist | 1 |
| 3 | Error 1213 and the deadlock section naming your database | 1 |
| 3 | Your three sentences (read by the instructor) | 1 |
| 4 | Each of webapp, report, etl, kiosk matches the spec exactly (0.5 each) | 2 |
| 4 | intern gone, kiosk locked, no `s<ID>_` account on host `%` | 1 |
| 4 | `audit.md` (read by the instructor) | 1 |
| 5 | `incident.sql` obeys every rule | 1 |
| 5 | `recover.sh` repairs your own incident | 0.5 |
| 5 | `recover.sh` repairs three classmates' incidents | 0.5 |
| 5 | `incident_log.md` (read by the instructor) | 1 |
| Bonus | Table scan before, index lookup after, in `EXPLAIN ANALYZE` | 1 |
| Bonus | Your foreign-key explanation (read by the instructor) | 1 |

---

## Before the deadline

- [ ] `student.txt` has your ID and name.
- [ ] `docker compose down -v`, `up -d --wait`, then `bash /work/bootstrap.sh` **twice**: both succeed.
- [ ] After that rebuild, `bash /work/baseline.sh` produces the same files you committed (`git status` shows no change in `baseline/`).
- [ ] Your incident, then `recover.sh`: the server matches the baseline.
- [ ] The example incident, then `recover.sh`: the server matches the baseline.
- [ ] `git status` is clean, `git push` done, and the files are visible on your fork on GitHub.

---

## Troubleshooting

| Symptom | Cause and fix |
|---|---|
| `403` or "Permission denied" on `git push` | You cloned the instructor's repo, not your fork. Fix: `git remote set-url origin https://github.com/<YOU>/lab5-challenge.git`, then push again. |
| "Authentication failed" on push | GitHub does not accept your account password for git. Windows: let Git Credential Manager open the browser. macOS/Linux: `gh auth login`. |
| "Virtualization not enabled", or WSL errors on Windows | Enable VT-x / AMD-V (SVM) in BIOS/UEFI, then `wsl --update` in an Administrator PowerShell. Or use Codespaces. |
| "Cannot connect to the Docker daemon" / "docker: command not found" | Start Docker Desktop and wait until it says it is running. Open a new terminal. |
| `no configuration file provided` | You are not in the repo folder. `cd` into it. |
| `bootstrap.sh: $'\r': command not found` | Your editor saved Windows line endings. Do not delete `.gitattributes`. Run `git add --renormalize .` and save the file again with "LF" line endings (VS Code: bottom-right corner). |
| A stray `\r` in the last column of loaded rows | Same cause, in the CSV. Fix line endings, and use `LINES TERMINATED BY '\n'`. |
| `ERROR 1290 … --secure-file-priv` | `LOAD DATA INFILE` can only read from the directory that `SELECT @@secure_file_priv;` names. |
| `Access denied for user 'root'@'localhost' (using password: NO)` | `/root/.my.cnf` is missing in this container. Run `bash /work/bootstrap.sh`, or use `mysql -uroot -p`. |
| The image download is slow or fails | Docker Hub limits anonymous downloads. Run `docker login` with a free Docker account, or try again later. |
| Linux: cannot edit or delete files the container created | They are owned by root: `sudo chown -R "$USER" .` |
| My packet folder is missing | Check `student.txt`. Then on your fork's GitHub page click **Sync fork**, and `git pull`. Still missing? Tell the instructor. |
| The instructor announced a fix to the repo | On your fork's GitHub page click **Sync fork → Update branch**, then `git pull`. |
