# Team database-design workshop

This guide turns the project idea into a first database design. It uses ordinary language first, then introduces the database words. Treat the first-version assumptions as decisions to discuss, not laws of nature.

## 1. Purpose, users, and boundaries

**Purpose sentence:** This system lets high-school students view their own subject grades, teachers enter grades for their assigned subjects, and school administrators manage academic records and access; it must remember each student's grade level and subject scores by academic year.

**Clearly not its job:** taking attendance. A school might expect attendance from a student system, but this project does not record it.

**Users:** students, teachers, and school administrators. Each has a different job and different access. A student must not see another student's records; a teacher may change only grades for their own assignments; an administrator manages the records and access rules.

## 2. Nouns: entity or attribute?

An **entity** is a kind of thing for which the database needs rows. An **attribute** is a fact stored about one of those things. A **relationship** connects entities; if the relationship has its own data or repeats over time, it often needs its own table.

| Noun users may say | Decision | Why |
|---|---|---|
| Student | Entity: `student` | Each student has an identity and can have records over several years. |
| Teacher | Entity: `teacher` | Each teacher has an identity and may receive many assignments. |
| Subject | Entity: `subject` | A subject is reused in different years/grade levels and can be assigned to teachers. |
| Academic year | Entity: `academic_year` | The same year is referenced by many student records and assignments. |
| Grade 10 / 11 / 12 | Entity: `grade_level` | These are the allowed level values. A record refers to one level; the number is an attribute. |
| Student's grade level in a year | Entity/record: `student_year_record` | This association changes over time and preserves history. |
| Teacher assigned to a subject | Entity/relationship: `teaching_assignment` | The assignment has its own year and grade level, and grades refer to it. |
| Subject grade / final score | Entity/record: `student_grade` | One row records one student's result for one assignment. The numeric score and date are attributes of that row. |
| User account | Entity: `user_account` | It represents a way a person is recognized for access; it links to a student or teacher when appropriate. |
| Role | Entity: `role` | Administrators manage role definitions and permissions are attached to roles. |
| Permission | Entity: `permission` | Each permission describes an allowed action. |
| Role–permission pair | Entity/relationship: `role_permission` | Roles and permissions are many-to-many, so a junction table stores each pair. |
| Student number, employee number, subject code, year label, permission code | Attributes that can be candidate keys | Each is a human-readable value intended to be unique in its table. |
| First name, last name, score, grade date, status, start/end date | Attributes | They describe a student, teacher, grade, year, or account; they do not need independent rows in this version. |
| Attendance, tuition payment, online class, timetable/schedule | Out-of-scope concepts | They are not stored by this project. |

**The longest discussion:** Is a “subject grade” just a score column on `student`? We decided it needs its own `student_grade` row because the score belongs to a particular student-year record and a particular teacher assignment. The score and graded date describe that result; separate columns like `grade10_math` would be hard to extend and would lose the connection to the year and teacher.

## 3. Candidate keys and primary-key choices

A **candidate key** is the smallest value or combination of values that uniquely identifies a row. One candidate key is selected as the **primary key (PK)**. The design uses generated numeric IDs for primary keys and keeps useful natural candidate keys as `UNIQUE` constraints.

| Entity/table | Candidate key(s) | Chosen primary key and reason |
|---|---|---|
| `student` | `student_id`; `student_number` | `student_id` (PK): stable internal reference even if a school changes its numbering rules. `student_number` remains unique and readable. |
| `teacher` | `teacher_id`; `employee_number` | `teacher_id` (PK): stable internal reference; employee number remains unique. |
| `subject` | `subject_id`; `subject_code` | `subject_id` (PK): short and stable foreign key; subject code remains unique. |
| `academic_year` | `academic_year_id`; `year_label` | `academic_year_id` (PK): stable foreign key; label such as `2025-2026` remains unique. |
| `grade_level` | `grade_level_id`; `level_number` | `grade_level_id` (PK): consistent foreign-key style; `level_number` is unique and constrained to 10–12. |
| `student_year_record` | `student_year_record_id`; (`student_id`, `academic_year_id`) | `student_year_record_id` (PK): simple reference from grades. The pair is also unique because one student has at most one level record per year. |
| `teaching_assignment` | `teaching_assignment_id`; (`academic_year_id`, `grade_level_id`, `subject_id`) | `teaching_assignment_id` (PK): simple reference from grades. The three-column pair is unique under our one-teacher-per-subject/level/year assumption. |
| `student_grade` | `student_grade_id`; (`student_year_record_id`, `teaching_assignment_id`) | `student_grade_id` (PK): simple reference for later edits/reports. The pair is unique because version 1 stores one final score for that student record and assignment. |
| `user_account` | `user_account_id`; `username` | `user_account_id` (PK): stable internal reference; username is a unique login label in the learning model. |
| `role` | `role_id`; `role_name` | `role_id` (PK): stable foreign key; role name remains unique. |
| `permission` | `permission_id`; `permission_code` | `permission_id` (PK): stable foreign key; permission code remains unique. |
| `role_permission` | (`role_id`, `permission_id`) | The pair is the PK: neither value alone identifies a permission assignment; the pair prevents duplicate grants. |

**Rejected key and the day it fails:** A student's full name is not a safe key. On the day two different students are both named “Sokha Kim,” a grade report joined by name could attach one student's grade to the other. We use a unique student number for a human-facing candidate key and an internal ID for database references.

## 4. Tables: “the system remembers …”

`[PK]` marks the primary key. `FK` means the value refers to another table. The unique constraints listed above are also part of the design even where not repeated below.

- The system remembers **students**, and for each one we know: `[PK] student_id`, `student_number`, `first_name`, `last_name`, and `status`.
- The system remembers **teachers**, and for each one we know: `[PK] teacher_id`, `employee_number`, `first_name`, `last_name`, and `status`.
- The system remembers **subjects**, and for each one we know: `[PK] subject_id`, `subject_code`, `subject_name`, and `status`.
- The system remembers **academic years**, and for each one we know: `[PK] academic_year_id`, `year_label`, `start_date`, and `end_date`.
- The system remembers **grade levels**, and for each one we know: `[PK] grade_level_id` and `level_number` (10, 11, or 12).
- The system remembers **student year records**, and for each one we know: `[PK] student_year_record_id`, `[FK] student_id`, `[FK] academic_year_id`, `[FK] grade_level_id`, and `status`.
- The system remembers **teaching assignments**, and for each one we know: `[PK] teaching_assignment_id`, `[FK] teacher_id`, `[FK] subject_id`, `[FK] academic_year_id`, and `[FK] grade_level_id`.
- The system remembers **student grades**, and for each one we know: `[PK] student_grade_id`, `[FK] student_year_record_id`, `[FK] teaching_assignment_id`, `score`, and `graded_on`.
- The system remembers **user accounts**, and for each one we know: `[PK] user_account_id`, `username`, `[FK] role_id`, optional `[FK] student_id`, optional `[FK] teacher_id`, and `status`. This learning table does not store passwords.
- The system remembers **roles**, and for each one we know: `[PK] role_id`, `role_name`, and `description`.
- The system remembers **permissions**, and for each one we know: `[PK] permission_id`, `permission_code`, and `description`.
- The system remembers **role–permission pairs**, and for each one we know: `[PK, FK] role_id` and `[PK, FK] permission_id`.

### Why the attributes are placed there

- A student's level is not a permanent property of the student, so `grade_level_id` belongs to `student_year_record`, alongside the year.
- A teacher is not permanently assigned to one subject, so teacher/subject/year/level belong together in `teaching_assignment`.
- A score belongs to the student's record for that year and the matching assignment, so the score and date belong in `student_grade`.
- The subject name belongs to `subject`; the assignment references the subject rather than copying its name.
- A username belongs to `user_account`; a role name/description belongs to `role`; permission details belong to `permission`.

## Permission sketch

| Role | Intended access |
|---|---|
| Student | Read their own student-year records and grades; read the subjects offered to their grade level/year. No grade edits. |
| Teacher | Read their own assignments and the matching student roster; insert/update grades only for those assignments. |
| Administrator | Manage student/teacher records, subjects, years, assignments, accounts, roles, permissions, and grades. |

The PostgreSQL lab demonstrates these rules with roles and row-level security. A database permission table is a learning model, not a production identity/authentication service.
