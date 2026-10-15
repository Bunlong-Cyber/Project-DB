-- Run after sql/reference/04_security.sql as the local database owner.
-- Custom app.* settings below are test fixtures, not secure authentication.
\set ON_ERROR_STOP on

SELECT student_id AS test_student_id FROM student
WHERE student_number = 'STU-1001' \gset
SELECT teacher_id AS test_teacher_id FROM teacher
WHERE employee_number = 'TCH-201' \gset
SELECT g.student_grade_id AS other_teacher_grade_id
FROM student_grade g
JOIN teaching_assignment ta USING (teaching_assignment_id)
JOIN teacher t USING (teacher_id)
WHERE t.employee_number <> 'TCH-201'
ORDER BY g.student_grade_id LIMIT 1 \gset

\echo 'Administrator can read all students'
SET ROLE scms_admin;
SELECT count(*) AS admin_student_rows FROM student;
RESET ROLE;

\echo 'Student sees one student record and only their own grades'
SET ROLE scms_student;
SET app.student_id = :'test_student_id';
SELECT count(*) AS visible_student_rows FROM student;
SELECT count(*) AS visible_student_year_rows FROM student_year_record;
SELECT count(*) AS visible_grade_rows FROM student_grade;
SELECT count(*) AS visible_report_rows FROM v_student_subject_grades;
SELECT has_table_privilege(current_user, 'student_grade', 'UPDATE')
       AS student_can_update_grades;
RESET app.student_id;
RESET ROLE;

\echo 'Teacher sees only their assignments and corresponding grades'
SET ROLE scms_teacher;
SET app.teacher_id = :'test_teacher_id';
SELECT count(*) AS visible_assignment_rows FROM teaching_assignment;
SELECT count(*) AS visible_roster_rows FROM student_year_record;
SELECT count(*) AS visible_grade_rows FROM student_grade;
UPDATE student_grade SET score = score
WHERE student_grade_id = :'other_teacher_grade_id';
\echo 'The UPDATE above should affect 0 rows: this grade belongs to another teacher.'
RESET app.teacher_id;
RESET ROLE;

\echo 'Inspect RLS policies'
SELECT schemaname, tablename, policyname, roles, cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
