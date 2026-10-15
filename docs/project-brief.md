# Student Academic Grade Management System

## What are we building?

We are designing a **database for a high school**. It keeps students' subject grades organized by academic year and grade level (Grade 10, Grade 11, or Grade 12). Students can see their own records. Teachers can enter or update grades only for subjects assigned to them. School administrators manage the school's records and access rules.

This is a **database learning project**, not a finished website or login application. We use fictional data. The project teaches tables, relationships, keys, constraints, queries, and basic database permissions.

## Who uses it?

| User | What they need to do |
|---|---|
| Student | Choose an academic year/grade level and view subjects and their own grades. They must not see another student's private academic record. |
| Teacher | View their assigned subjects and the students taking them; enter or correct grades only for their own assignments. |
| School administrator | Add and manage student and teacher records, subjects, academic years, assignments, user accounts, roles, permissions, and academic records. |

The account and role tables describe who a user is. The PostgreSQL security exercises demonstrate access rules. They do **not** build production authentication or store passwords.

## What data is in scope?

- Students and teachers
- Subjects and the Grade 10–12 levels
- Academic years, such as `2025-2026`
- A student's grade level for each academic year, preserving their history as they advance
- Teacher assignments to a subject for a grade level and academic year
- One final subject score for a student in that grade level/year
- User accounts, roles, and the permissions associated with each role

## What is out of scope?

- Attendance
- Tuition or other payments
- Online classes or learning materials
- Class timetables, rooms, and scheduling
- A website/mobile app or production login/password system
- Real student or staff data

If someone expects one of these features, note it as a future idea; do not quietly add it to this first database.

## First-version design assumptions

These assumptions keep the first version small enough for a beginner team. Record a team decision if you change one:

1. Each student has one grade-level record per academic year. The same student can have records in several years, so past grades remain attached to the correct year and level.
2. For each combination of academic year, grade level, and subject, there is one responsible teacher. If the school needs multiple classes or teachers for the same combination, we must design a `class_section` entity before adding that feature.
3. A student receives one final numeric score (0–100) per subject in each academic year/grade level. Separate exams, terms, or report periods are future scope.
4. A subject is offered to a grade/year through its teacher assignment. This lets the database show which subjects a student should see for that year and level.
5. Grade levels are only 10, 11, and 12 in this version. Academic years and grade levels are separate concepts: `Grade 10` is a level; `2025-2026` is a year.
6. User accounts link to a student or teacher when appropriate. The administrator account is not linked to either. Passwords are not stored in this learning database.

## Questions the database should answer

- Which subjects and grades belong to one student's Grade 10 record in `2025-2026`?
- Which subjects are assigned to Grade 11 in a selected academic year?
- Which students and grades are connected to a teacher's assignment?
- Which students are missing a final score for an assigned subject?
- What is a student's average score for a selected year and grade level?
- Can a student see only their own records, and can a teacher change grades only for their assignments?

## Database rules we will practice

- Use primary keys to identify rows and foreign keys to connect related rows.
- Use `NOT NULL`, `UNIQUE`, `CHECK`, and sensible defaults to reject invalid data.
- Keep a student's academic-year history; do not overwrite last year's grade level or grades.
- Use fictional people and `example.com` email addresses only.
- Explain each table and relationship before copying the reference SQL.

For the beginner-friendly entity list, key choices, and sentence-based design exercise, see [`team-design-workshop.md`](team-design-workshop.md). For the relationship diagram, see [`erd.md`](erd.md).
