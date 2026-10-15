-- PostgreSQL security demonstration for a disposable learning database.
-- This models authorization; it is NOT production authentication.

REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO PUBLIC;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'scms_admin') THEN
        CREATE ROLE scms_admin NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'scms_teacher') THEN
        CREATE ROLE scms_teacher NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'scms_student') THEN
        CREATE ROLE scms_student NOLOGIN;
    END IF;
END
$$;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO scms_admin;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO scms_admin;

GRANT SELECT ON teacher, subject, academic_year, grade_level,
    student, student_year_record, teaching_assignment, student_grade,
    v_teacher_assignments TO scms_teacher;
GRANT INSERT (student_year_record_id, teaching_assignment_id, score, graded_on),
    UPDATE (score, graded_on) ON student_grade TO scms_teacher;

GRANT SELECT ON student, academic_year, grade_level, subject,
    teacher, student_year_record, teaching_assignment, student_grade,
    v_student_subject_grades TO scms_student;

ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM PUBLIC;

ALTER TABLE student ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_year_record ENABLE ROW LEVEL SECURITY;
ALTER TABLE teaching_assignment ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_grade ENABLE ROW LEVEL SECURITY;
ALTER TABLE student FORCE ROW LEVEL SECURITY;
ALTER TABLE student_year_record FORCE ROW LEVEL SECURITY;
ALTER TABLE teaching_assignment FORCE ROW LEVEL SECURITY;
ALTER TABLE student_grade FORCE ROW LEVEL SECURITY;

-- Students can see themselves and their own year/grade history.
CREATE POLICY student_self ON student FOR SELECT TO scms_student
    USING (student_id = NULLIF(current_setting('app.student_id', true), '')::INTEGER);
CREATE POLICY student_year_self ON student_year_record FOR SELECT TO scms_student
    USING (student_id = NULLIF(current_setting('app.student_id', true), '')::INTEGER);
CREATE POLICY assignment_for_student_year ON teaching_assignment FOR SELECT TO scms_student
    USING (EXISTS (
        SELECT 1 FROM student_year_record syr
        WHERE syr.student_id = NULLIF(current_setting('app.student_id', true), '')::INTEGER
          AND syr.academic_year_id = teaching_assignment.academic_year_id
          AND syr.grade_level_id = teaching_assignment.grade_level_id
    ));
CREATE POLICY grade_self ON student_grade FOR SELECT TO scms_student
    USING (EXISTS (
        SELECT 1 FROM student_year_record syr
        WHERE syr.student_year_record_id = student_grade.student_year_record_id
          AND syr.student_id = NULLIF(current_setting('app.student_id', true), '')::INTEGER
    ));

-- Teachers can see their own assignments and only the matching student roster/grades.
CREATE POLICY teacher_student_roster ON student FOR SELECT TO scms_teacher
    USING (EXISTS (
        SELECT 1 FROM student_year_record syr
        WHERE syr.student_id = student.student_id
    ));
CREATE POLICY teacher_year_roster ON student_year_record FOR SELECT TO scms_teacher
    USING (EXISTS (
        SELECT 1 FROM teaching_assignment ta
        WHERE ta.academic_year_id = student_year_record.academic_year_id
          AND ta.grade_level_id = student_year_record.grade_level_id
          AND ta.teacher_id = NULLIF(current_setting('app.teacher_id', true), '')::INTEGER
    ));
CREATE POLICY teacher_own_assignment ON teaching_assignment FOR SELECT TO scms_teacher
    USING (teacher_id = NULLIF(current_setting('app.teacher_id', true), '')::INTEGER);
CREATE POLICY teacher_grade_select ON student_grade FOR SELECT TO scms_teacher
    USING (EXISTS (
        SELECT 1 FROM teaching_assignment ta
        WHERE ta.teaching_assignment_id = student_grade.teaching_assignment_id
          AND ta.teacher_id = NULLIF(current_setting('app.teacher_id', true), '')::INTEGER
    ));
CREATE POLICY teacher_grade_insert ON student_grade FOR INSERT TO scms_teacher
    WITH CHECK (EXISTS (
        SELECT 1 FROM teaching_assignment ta
        WHERE ta.teaching_assignment_id = student_grade.teaching_assignment_id
          AND ta.teacher_id = NULLIF(current_setting('app.teacher_id', true), '')::INTEGER
    ));
CREATE POLICY teacher_grade_update ON student_grade FOR UPDATE TO scms_teacher
    USING (EXISTS (
        SELECT 1 FROM teaching_assignment ta
        WHERE ta.teaching_assignment_id = student_grade.teaching_assignment_id
          AND ta.teacher_id = NULLIF(current_setting('app.teacher_id', true), '')::INTEGER
    ))
    WITH CHECK (EXISTS (
        SELECT 1 FROM teaching_assignment ta
        WHERE ta.teaching_assignment_id = student_grade.teaching_assignment_id
          AND ta.teacher_id = NULLIF(current_setting('app.teacher_id', true), '')::INTEGER
    ));

-- Administrators can manage all rows in the protected academic tables.
CREATE POLICY admin_student_all ON student FOR ALL TO scms_admin USING (true) WITH CHECK (true);
CREATE POLICY admin_student_year_all ON student_year_record FOR ALL TO scms_admin USING (true) WITH CHECK (true);
CREATE POLICY admin_assignment_all ON teaching_assignment FOR ALL TO scms_admin USING (true) WITH CHECK (true);
CREATE POLICY admin_grade_all ON student_grade FOR ALL TO scms_admin USING (true) WITH CHECK (true);

COMMENT ON POLICY grade_self ON student_grade IS 'Student sees grades connected to their own student-year records.';
COMMENT ON POLICY teacher_grade_update ON student_grade IS 'Teacher can update only grades for their assigned subject/year/level.';
