-- Integrity checks for the complete reference database. No permanent changes.
\set ON_ERROR_STOP on

\echo '1. Fictional reference data counts'
SELECT 'student' AS table_name, 4 AS expected, count(*)::int AS actual FROM student
UNION ALL SELECT 'teacher', 3, count(*)::int FROM teacher
UNION ALL SELECT 'subject', 4, count(*)::int FROM subject
UNION ALL SELECT 'academic_year', 2, count(*)::int FROM academic_year
UNION ALL SELECT 'grade_level', 3, count(*)::int FROM grade_level
UNION ALL SELECT 'student_year_record', 5, count(*)::int FROM student_year_record
UNION ALL SELECT 'teaching_assignment', 7, count(*)::int FROM teaching_assignment
UNION ALL SELECT 'student_grade', 8, count(*)::int FROM student_grade
ORDER BY table_name;

\echo '2. No grade crosses a year or grade-level boundary'
SELECT count(*) AS mismatches,
       CASE WHEN count(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM student_grade g
JOIN student_year_record syr USING (student_year_record_id)
JOIN teaching_assignment ta USING (teaching_assignment_id)
WHERE syr.academic_year_id <> ta.academic_year_id
   OR syr.grade_level_id <> ta.grade_level_id;

\echo '3. Constraints reject duplicate year records and invalid scores'
BEGIN;
\set ON_ERROR_STOP off
SAVEPOINT duplicate_student_year;
INSERT INTO student_year_record (student_id, academic_year_id, grade_level_id)
SELECT student_id, academic_year_id, grade_level_id
FROM student_year_record LIMIT 1;
ROLLBACK TO SAVEPOINT duplicate_student_year;
\echo 'Expected UNIQUE error appeared above.'
SAVEPOINT invalid_score;
UPDATE student_grade SET score = 150 WHERE student_grade_id = 1;
ROLLBACK TO SAVEPOINT invalid_score;
\echo 'Expected CHECK error appeared above.'
SAVEPOINT mismatched_context;
INSERT INTO student_grade (student_year_record_id, teaching_assignment_id, score)
SELECT syr.student_year_record_id, ta.teaching_assignment_id, 50
FROM student_year_record syr
CROSS JOIN teaching_assignment ta
WHERE syr.academic_year_id <> ta.academic_year_id
   OR syr.grade_level_id <> ta.grade_level_id
LIMIT 1;
ROLLBACK TO SAVEPOINT mismatched_context;
\echo 'Expected trigger error appeared above.'
ROLLBACK;
\set ON_ERROR_STOP on

\echo '4. Transaction rollback demonstration'
BEGIN;
SELECT score AS before_rollback FROM student_grade WHERE student_grade_id = 1;
UPDATE student_grade SET score = 0 WHERE student_grade_id = 1;
ROLLBACK;
SELECT score AS after_rollback FROM student_grade WHERE student_grade_id = 1;

\echo '5. Report views'
SELECT count(*) AS joined_grade_rows FROM v_student_subject_grades;
SELECT count(*) AS teacher_assignment_rows FROM v_teacher_assignments;
