-- Fictional sample data only. Run once, after reference/01_schema.sql.
BEGIN;

INSERT INTO academic_year (year_label, start_date, end_date) VALUES
    ('2025-2026', DATE '2025-11-01', DATE '2026-08-31'),
    ('2026-2027', DATE '2026-11-01', DATE '2027-08-31');

INSERT INTO grade_level (level_number) VALUES (10), (11), (12);

INSERT INTO subject (subject_code, subject_name) VALUES
    ('MATH', 'Mathematics'),
    ('ENGLISH', 'English'),
    ('BIO', 'Biology'),
    ('KHMER', 'Khmer Language');

INSERT INTO student (student_number, first_name, last_name) VALUES
    ('STU-1001', 'Dara', 'Sok'),
    ('STU-1002', 'Sokha', 'Kim'),
    ('STU-1003', 'Sokha', 'Kim'), -- Different student, deliberately same name.
    ('STU-1004', 'Bopha', 'Chan');

INSERT INTO teacher (employee_number, first_name, last_name) VALUES
    ('TCH-201', 'Malis', 'Touch'),
    ('TCH-202', 'Ravy', 'Chhim'),
    ('TCH-203', 'Sokun', 'Yuth');

INSERT INTO role (role_name, description) VALUES
    ('Student', 'Views their own academic history'),
    ('Teacher', 'Views assigned students and manages assigned grades'),
    ('Administrator', 'Manages school academic records and access');

INSERT INTO permission (permission_code, description) VALUES
    ('grade.view_own', 'View the grades belonging to the signed-in student'),
    ('subject.view_offered', 'View subjects offered for a grade level and year'),
    ('assignment.view_own', 'View the signed-in teacher assignments'),
    ('grade.enter_assigned', 'Enter or update a grade for an assigned subject'),
    ('academic.manage', 'Manage students, teachers, years, subjects, and grades'),
    ('access.manage', 'Manage accounts, roles, and permissions');

INSERT INTO role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM (VALUES
    ('Student', 'grade.view_own'),
    ('Student', 'subject.view_offered'),
    ('Teacher', 'assignment.view_own'),
    ('Teacher', 'grade.enter_assigned')
) AS grants(role_name, permission_code)
JOIN role r USING (role_name)
JOIN permission p USING (permission_code);

INSERT INTO role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM role r CROSS JOIN permission p
WHERE r.role_name = 'Administrator';

INSERT INTO student_year_record (student_id, academic_year_id, grade_level_id, status)
SELECT s.student_id, y.academic_year_id, gl.grade_level_id, v.status
FROM (VALUES
    ('STU-1001', '2025-2026', 10, 'Completed'),
    ('STU-1001', '2026-2027', 11, 'Enrolled'),
    ('STU-1002', '2026-2027', 10, 'Enrolled'),
    ('STU-1003', '2026-2027', 10, 'Enrolled'),
    ('STU-1004', '2026-2027', 11, 'Enrolled')
) AS v(student_number, year_label, level_number, status)
JOIN student s USING (student_number)
JOIN academic_year y USING (year_label)
JOIN grade_level gl USING (level_number);

INSERT INTO teaching_assignment
    (teacher_id, subject_id, academic_year_id, grade_level_id)
SELECT t.teacher_id, sub.subject_id, y.academic_year_id, gl.grade_level_id
FROM (VALUES
    ('TCH-201', 'MATH',    '2025-2026', 10),
    ('TCH-202', 'ENGLISH', '2025-2026', 10),
    ('TCH-201', 'MATH',    '2026-2027', 10),
    ('TCH-202', 'ENGLISH', '2026-2027', 10),
    ('TCH-203', 'BIO',     '2026-2027', 10),
    ('TCH-201', 'MATH',    '2026-2027', 11),
    ('TCH-202', 'KHMER',   '2026-2027', 11)
) AS v(employee_number, subject_code, year_label, level_number)
JOIN teacher t USING (employee_number)
JOIN subject sub USING (subject_code)
JOIN academic_year y USING (year_label)
JOIN grade_level gl USING (level_number);

INSERT INTO student_grade
    (student_year_record_id, teaching_assignment_id, score, graded_on)
SELECT syr.student_year_record_id, ta.teaching_assignment_id, v.score, DATE '2027-06-15'
FROM (VALUES
    ('STU-1001', '2025-2026', 10, 'MATH',    87.00),
    ('STU-1001', '2025-2026', 10, 'ENGLISH', 90.00),
    ('STU-1001', '2026-2027', 11, 'MATH',    80.00),
    ('STU-1001', '2026-2027', 11, 'KHMER',   88.00),
    ('STU-1002', '2026-2027', 10, 'MATH',    72.00),
    ('STU-1003', '2026-2027', 10, 'BIO',     95.00),
    ('STU-1003', '2026-2027', 10, 'ENGLISH', 91.00),
    ('STU-1004', '2026-2027', 11, 'MATH',    76.00)
) AS v(student_number, year_label, level_number, subject_code, score)
JOIN student s USING (student_number)
JOIN academic_year y USING (year_label)
JOIN grade_level gl USING (level_number)
JOIN student_year_record syr ON syr.student_id = s.student_id
    AND syr.academic_year_id = y.academic_year_id
    AND syr.grade_level_id = gl.grade_level_id
JOIN subject sub USING (subject_code)
JOIN teaching_assignment ta ON ta.subject_id = sub.subject_id
    AND ta.academic_year_id = y.academic_year_id
    AND ta.grade_level_id = gl.grade_level_id;

INSERT INTO user_account (username, role_id, student_id)
SELECT 'student1001', r.role_id, s.student_id
FROM role r CROSS JOIN student s
WHERE r.role_name = 'Student' AND s.student_number = 'STU-1001';

INSERT INTO user_account (username, role_id, teacher_id)
SELECT 'teacher201', r.role_id, t.teacher_id
FROM role r CROSS JOIN teacher t
WHERE r.role_name = 'Teacher' AND t.employee_number = 'TCH-201';

INSERT INTO user_account (username, role_id)
SELECT 'schooladmin', role_id FROM role WHERE role_name = 'Administrator';

COMMIT;

-- Expected counts: 2 years, 3 grade levels, 4 subjects, 4 students,
-- 3 teachers, 5 student-year records, 7 assignments, and 8 final grades.
