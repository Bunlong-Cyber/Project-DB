-- Student Academic Grade Management System — reference schema (PostgreSQL 16+)
-- Run once in a fresh, disposable learning database. Data is fictional.

CREATE TABLE academic_year (
    academic_year_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    year_label       VARCHAR(20) NOT NULL UNIQUE,
    start_date       DATE NOT NULL,
    end_date         DATE NOT NULL,
    CHECK (start_date < end_date)
);

CREATE TABLE grade_level (
    grade_level_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    level_number   SMALLINT NOT NULL UNIQUE CHECK (level_number IN (10, 11, 12))
);

CREATE TABLE subject (
    subject_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    subject_code VARCHAR(15) NOT NULL UNIQUE,
    subject_name VARCHAR(100) NOT NULL,
    status       VARCHAR(10) NOT NULL DEFAULT 'Active'
                 CHECK (status IN ('Active', 'Archived'))
);

CREATE TABLE student (
    student_id     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_number VARCHAR(20) NOT NULL UNIQUE,
    first_name     VARCHAR(50) NOT NULL,
    last_name      VARCHAR(50) NOT NULL,
    status         VARCHAR(12) NOT NULL DEFAULT 'Active'
                   CHECK (status IN ('Active', 'Graduated', 'Withdrawn'))
);

CREATE TABLE teacher (
    teacher_id     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_number VARCHAR(20) NOT NULL UNIQUE,
    first_name     VARCHAR(50) NOT NULL,
    last_name      VARCHAR(50) NOT NULL,
    status         VARCHAR(12) NOT NULL DEFAULT 'Active'
                   CHECK (status IN ('Active', 'On Leave', 'Inactive'))
);

CREATE TABLE role (
    role_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_name VARCHAR(20) NOT NULL UNIQUE
              CHECK (role_name IN ('Student', 'Teacher', 'Administrator')),
    description TEXT
);

CREATE TABLE permission (
    permission_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    permission_code VARCHAR(50) NOT NULL UNIQUE,
    description     TEXT NOT NULL
);

CREATE TABLE student_year_record (
    student_year_record_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_id             INTEGER NOT NULL REFERENCES student (student_id) ON DELETE RESTRICT,
    academic_year_id       INTEGER NOT NULL REFERENCES academic_year (academic_year_id) ON DELETE RESTRICT,
    grade_level_id         INTEGER NOT NULL REFERENCES grade_level (grade_level_id) ON DELETE RESTRICT,
    status                 VARCHAR(12) NOT NULL DEFAULT 'Enrolled'
                           CHECK (status IN ('Enrolled', 'Completed', 'Withdrawn')),
    UNIQUE (student_id, academic_year_id),
    -- Supports clear, multi-column references where year/level consistency matters.
    UNIQUE (student_year_record_id, academic_year_id, grade_level_id)
);

CREATE TABLE teaching_assignment (
    teaching_assignment_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    teacher_id             INTEGER NOT NULL REFERENCES teacher (teacher_id) ON DELETE RESTRICT,
    subject_id             INTEGER NOT NULL REFERENCES subject (subject_id) ON DELETE RESTRICT,
    academic_year_id       INTEGER NOT NULL REFERENCES academic_year (academic_year_id) ON DELETE RESTRICT,
    grade_level_id         INTEGER NOT NULL REFERENCES grade_level (grade_level_id) ON DELETE RESTRICT,
    -- Version 1 assumes one responsible teacher per subject/level/year.
    UNIQUE (academic_year_id, grade_level_id, subject_id),
    UNIQUE (teaching_assignment_id, academic_year_id, grade_level_id)
);

CREATE TABLE user_account (
    user_account_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username        VARCHAR(63) NOT NULL UNIQUE,
    role_id         INTEGER NOT NULL REFERENCES role (role_id) ON DELETE RESTRICT,
    student_id      INTEGER UNIQUE REFERENCES student (student_id) ON DELETE RESTRICT,
    teacher_id      INTEGER UNIQUE REFERENCES teacher (teacher_id) ON DELETE RESTRICT,
    status          VARCHAR(10) NOT NULL DEFAULT 'Active'
                    CHECK (status IN ('Active', 'Disabled')),
    CHECK (student_id IS NULL OR teacher_id IS NULL)
);

CREATE TABLE role_permission (
    role_id       INTEGER NOT NULL REFERENCES role (role_id) ON DELETE CASCADE,
    permission_id INTEGER NOT NULL REFERENCES permission (permission_id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE student_grade (
    student_grade_id       INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_year_record_id INTEGER NOT NULL,
    teaching_assignment_id INTEGER NOT NULL,
    score                  NUMERIC(5,2) NOT NULL CHECK (score BETWEEN 0 AND 100),
    graded_on              DATE NOT NULL DEFAULT CURRENT_DATE,
    UNIQUE (student_year_record_id, teaching_assignment_id),
    FOREIGN KEY (student_year_record_id)
        REFERENCES student_year_record (student_year_record_id) ON DELETE RESTRICT,
    FOREIGN KEY (teaching_assignment_id)
        REFERENCES teaching_assignment (teaching_assignment_id) ON DELETE RESTRICT
);

-- A normal FK checks that both referenced rows exist, but cannot by itself
-- verify their year and grade level agree. This trigger enforces that rule
-- without copying year/level columns into student_grade.
CREATE FUNCTION check_student_grade_context() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
    student_year INTEGER;
    student_level INTEGER;
    assignment_year INTEGER;
    assignment_level INTEGER;
BEGIN
    SELECT academic_year_id, grade_level_id
      INTO student_year, student_level
      FROM student_year_record
     WHERE student_year_record_id = NEW.student_year_record_id;

    SELECT academic_year_id, grade_level_id
      INTO assignment_year, assignment_level
      FROM teaching_assignment
     WHERE teaching_assignment_id = NEW.teaching_assignment_id;

    IF student_year IS DISTINCT FROM assignment_year
       OR student_level IS DISTINCT FROM assignment_level THEN
        RAISE EXCEPTION 'student record and teacher assignment must use the same academic year and grade level';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_check_student_grade_context
BEFORE INSERT OR UPDATE OF student_year_record_id, teaching_assignment_id
ON student_grade
FOR EACH ROW EXECUTE FUNCTION check_student_grade_context();

-- An account's role must match its linked academic identity. Administrator
-- accounts have no student/teacher link. This still does not authenticate anyone.
CREATE FUNCTION check_user_account_identity() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
    assigned_role VARCHAR(20);
BEGIN
    SELECT role_name INTO assigned_role FROM role WHERE role_id = NEW.role_id;
    IF (assigned_role = 'Student' AND (NEW.student_id IS NULL OR NEW.teacher_id IS NOT NULL))
       OR (assigned_role = 'Teacher' AND (NEW.teacher_id IS NULL OR NEW.student_id IS NOT NULL))
       OR (assigned_role = 'Administrator' AND (NEW.student_id IS NOT NULL OR NEW.teacher_id IS NOT NULL)) THEN
        RAISE EXCEPTION 'account links must match its role';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_check_user_account_identity
BEFORE INSERT OR UPDATE OF role_id, student_id, teacher_id
ON user_account
FOR EACH ROW EXECUTE FUNCTION check_user_account_identity();

CREATE INDEX idx_student_year_student ON student_year_record (student_id, academic_year_id);
CREATE INDEX idx_assignment_teacher ON teaching_assignment (teacher_id, academic_year_id, grade_level_id);
CREATE INDEX idx_assignment_subject ON teaching_assignment (subject_id, academic_year_id, grade_level_id);
CREATE INDEX idx_student_grade_assignment ON student_grade (teaching_assignment_id);
CREATE INDEX idx_user_account_role ON user_account (role_id);

COMMENT ON TABLE student_year_record IS 'One student placement in one grade level during one academic year; preserves history.';
COMMENT ON TABLE teaching_assignment IS 'One responsible teacher for a subject, grade level, and academic year in version 1.';
COMMENT ON TABLE student_grade IS 'One final numeric subject score for one student-year record and matching teaching assignment.';
COMMENT ON TABLE role_permission IS 'Junction table: a role may have many permissions and a permission may belong to many roles.';
COMMENT ON TABLE user_account IS 'Learning model for account-to-person and role links; not an authentication/password store.';
