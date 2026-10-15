-- Student Academic Grade Management System — starter schema (PostgreSQL 16+)
-- This file is an exercise. Work in a fresh, disposable practice database.
-- Do not run it unchanged more than once in the same database.

-- Worked example: a reusable lookup table for the three allowed levels.
CREATE TABLE grade_level (
    grade_level_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    level_number   SMALLINT NOT NULL UNIQUE CHECK (level_number IN (10, 11, 12))
);

-- Worked example: a student has an independent row. The school number is a
-- human-facing unique key; the generated ID is the stable database key.
CREATE TABLE student (
    student_id     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    student_number VARCHAR(20) NOT NULL UNIQUE,
    first_name     VARCHAR(50) NOT NULL,
    last_name      VARCHAR(50) NOT NULL,
    status         VARCHAR(12) NOT NULL DEFAULT 'Active'
                   CHECK (status IN ('Active', 'Graduated', 'Withdrawn'))
);

-- TODO 1: Create academic_year.
-- Suggested columns: generated PK; unique year_label (e.g. '2025-2026');
-- start_date; end_date; CHECK that start_date is earlier than end_date.

-- TODO 2: Create teacher.
-- Suggested columns: generated PK; unique employee_number; first_name;
-- last_name; status with a CHECK. Do not store a password.

-- TODO 3: Create subject.
-- Suggested columns: generated PK; unique subject_code; subject_name;
-- status. A subject can be reused in multiple years and grade levels.

-- TODO 4: Create student_year_record AFTER academic_year and grade_level.
-- One row says which grade level one student was in during one academic year.
-- Include FKs, status, and UNIQUE (student_id, academic_year_id).

-- TODO 5: Create teaching_assignment AFTER teacher, subject, academic_year,
-- and grade_level. It connects one teacher + subject + year + grade level.
-- Version 1 assumes UNIQUE (academic_year_id, grade_level_id, subject_id).

-- TODO 6: Create student_grade AFTER student_year_record and
-- teaching_assignment. Include FKs, score NUMERIC(5,2) CHECKed from 0 to 100,
-- graded_on, and UNIQUE (student_year_record_id, teaching_assignment_id).
-- The reference also checks that both FKs use the same year and grade level.

-- TODO 7: Create role, permission, role_permission, and user_account.
-- role_permission is a junction table with a composite PK of both FKs.
-- An account may link to one student OR one teacher; an admin links to neither.
-- Never store plaintext passwords in this learning database.

-- TODO 8: Add useful indexes to foreign-key columns after considering the
-- queries in 03_query_practice.sql. PK/UNIQUE constraints already create indexes.
