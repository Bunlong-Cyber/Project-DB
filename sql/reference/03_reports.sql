-- Views and example reports. Run after schema and fictional seed data.

CREATE VIEW v_student_subject_grades WITH (security_invoker = true) AS
SELECT s.student_number, s.first_name, s.last_name,
       y.year_label, gl.level_number,
       sub.subject_code, sub.subject_name,
       t.employee_number AS teacher_number, t.first_name AS teacher_first_name,
       t.last_name AS teacher_last_name, g.score, g.graded_on
FROM student_grade g
JOIN student_year_record syr USING (student_year_record_id)
JOIN student s USING (student_id)
JOIN academic_year y USING (academic_year_id)
JOIN grade_level gl USING (grade_level_id)
JOIN teaching_assignment ta USING (teaching_assignment_id)
JOIN subject sub USING (subject_id)
JOIN teacher t USING (teacher_id);

CREATE VIEW v_teacher_assignments WITH (security_invoker = true) AS
SELECT t.employee_number, t.first_name AS teacher_first_name,
       t.last_name AS teacher_last_name,
       y.year_label, gl.level_number, sub.subject_code, sub.subject_name
FROM teaching_assignment ta
JOIN teacher t USING (teacher_id)
JOIN academic_year y USING (academic_year_id)
JOIN grade_level gl USING (grade_level_id)
JOIN subject sub USING (subject_id);

-- 1. One student's scores by academic year and grade level.
SELECT year_label, level_number, subject_code, subject_name, score
FROM v_student_subject_grades
WHERE student_number = 'STU-1001'
ORDER BY year_label, subject_code;

-- 2. Subjects available to Grade 10 in one academic year (even before grades).
SELECT y.year_label, gl.level_number, sub.subject_code, sub.subject_name,
       t.first_name || ' ' || t.last_name AS teacher
FROM teaching_assignment ta
JOIN academic_year y USING (academic_year_id)
JOIN grade_level gl USING (grade_level_id)
JOIN subject sub USING (subject_id)
JOIN teacher t USING (teacher_id)
WHERE y.year_label = '2026-2027' AND gl.level_number = 10
ORDER BY sub.subject_name;

-- 3. Student roster for one teacher assignment.
SELECT s.student_number, s.first_name, s.last_name, sub.subject_name,
       y.year_label, gl.level_number, g.score
FROM teaching_assignment ta
JOIN student_year_record syr
  ON syr.academic_year_id = ta.academic_year_id
 AND syr.grade_level_id = ta.grade_level_id
JOIN student s USING (student_id)
JOIN subject sub ON sub.subject_id = ta.subject_id
JOIN academic_year y ON y.academic_year_id = ta.academic_year_id
JOIN grade_level gl ON gl.grade_level_id = ta.grade_level_id
LEFT JOIN student_grade g
  ON g.student_year_record_id = syr.student_year_record_id
 AND g.teaching_assignment_id = ta.teaching_assignment_id
WHERE ta.teaching_assignment_id = 1
ORDER BY s.last_name, s.first_name;

-- 4. Missing final scores for a student's assigned subjects.
SELECT s.student_number, y.year_label, gl.level_number, sub.subject_name
FROM student_year_record syr
JOIN student s USING (student_id)
JOIN academic_year y USING (academic_year_id)
JOIN grade_level gl USING (grade_level_id)
JOIN teaching_assignment ta
  ON ta.academic_year_id = syr.academic_year_id
 AND ta.grade_level_id = syr.grade_level_id
JOIN subject sub USING (subject_id)
LEFT JOIN student_grade g
  ON g.student_year_record_id = syr.student_year_record_id
 AND g.teaching_assignment_id = ta.teaching_assignment_id
WHERE g.student_grade_id IS NULL
ORDER BY s.student_number, sub.subject_name;

-- 5. Average score by student and academic year/grade level.
SELECT s.student_number, s.first_name, s.last_name, y.year_label,
       gl.level_number, round(avg(g.score), 2) AS average_score
FROM student_grade g
JOIN student_year_record syr USING (student_year_record_id)
JOIN student s USING (student_id)
JOIN academic_year y USING (academic_year_id)
JOIN grade_level gl USING (grade_level_id)
GROUP BY s.student_number, s.first_name, s.last_name, y.year_label, gl.level_number
ORDER BY s.student_number, y.year_label;

-- 6. Score summary by subject and academic year.
SELECT y.year_label, sub.subject_name,
       count(g.student_grade_id) AS graded_students,
       round(avg(g.score), 2) AS average_score,
       min(g.score) AS lowest_score, max(g.score) AS highest_score
FROM teaching_assignment ta
JOIN academic_year y USING (academic_year_id)
JOIN subject sub USING (subject_id)
LEFT JOIN student_grade g USING (teaching_assignment_id)
GROUP BY y.year_label, sub.subject_name
ORDER BY y.year_label, sub.subject_name;
