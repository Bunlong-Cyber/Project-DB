# Beginner learning roadmap

Go slowly enough that every team member can explain the choices. The goal is not to type the most SQL; it is to understand why the tables and rules exist.

## Week 1 — Understand the system and PostgreSQL

- Read `project-brief.md` and `team-design-workshop.md` together.
- Learn database, table, row, column, primary key, and foreign key.
- Run the temporary-table exercise in `00-before-postgresql.md`.
- **Deliverable:** each team member can describe one user and one thing the system remembers.

## Week 2 — Sort things into entities and attributes

- List the nouns students, teachers, and administrators use.
- Decide which nouns are things with their own rows and which are facts describing those things.
- Discuss the key choices in `team-design-workshop.md`; write down disagreements and decisions.
- Draw or read `erd.md`; explain each relationship in everyday language.
- **Deliverable:** an agreed entity list and a hand-drawn ERD.

## Week 3 — Keys, tables, and constraints

- Learn candidate key, primary key, alternate key, `NOT NULL`, `UNIQUE`, `CHECK`, and foreign key.
- Work through the examples in `sql/01_schema_starter.sql`.
- Add the remaining tables in parent-before-child order.
- **Deliverable:** starter schema and a short explanation of each key.

## Week 4 — Fictional data and SQL queries

- Add a few students, teachers, academic years, grade levels, subjects, assignments, and scores.
- Practice `SELECT`, `WHERE`, `ORDER BY`, `JOIN`, `LEFT JOIN`, `GROUP BY`, `COUNT`, and `AVG`.
- Use `sql/03_query_practice.sql` to answer the questions in the project brief.
- **Deliverable:** sample data and useful grade reports.

## Week 5 — Test the rules and preserve history

- Try to insert a duplicate student number, an impossible grade level, a score below 0 or above 100, and a grade for the wrong year/level.
- Confirm the database rejects each invalid case.
- Demonstrate a transaction with `ROLLBACK` so a test change does not remain.
- **Deliverable:** test notes showing expected and actual results.

## Week 6 — Users, roles, and permissions

- Read the permission matrix in `team-design-workshop.md`.
- Complete `sql/04_security_starter.sql` using least privilege.
- Demonstrate that students cannot edit grades and teachers cannot change grades for another teacher's assignment.
- Remember: PostgreSQL roles and row-level security in this lab are a learning demonstration, not a complete production login system.
- **Deliverable:** a permission matrix and repeatable allowed/denied tests.

## Final self-check

- Can every team member explain what the system does and what it deliberately does not do?
- Can you explain why one student has multiple year records?
- Can you trace a grade from student → year record → assignment → subject and teacher?
- Can you explain each primary key and one rejected candidate key?
- Can you reproduce the reference tests in a disposable local database?
