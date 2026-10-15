# PostgreSQL basics before the project

Do not begin by copying the complete schema. First learn how to make a small table, insert rows, read them, change them, and remove them.

## The basic mental model

- **Database:** a container for related tables.
- **Table:** a structured set of records, similar to a spreadsheet with rules.
- **Row:** one record, such as one student.
- **Column:** one fact about that record, such as a first name.
- **Primary key:** a value that identifies one row.
- **Foreign key:** a value that points to a row in another table.
- **SQL:** the language used to define tables and work with their data.

## First practice session

Start the private lab:

```bash
./scripts/start-lab.sh
psql -h "$HOME/.local/share/scms-grade-pg-lab/socket" -p 55442 \
  -U "$USER" -d scms_reference
```

Use a temporary table so you do not change the project data:

```sql
CREATE TEMPORARY TABLE practice_student (
    student_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name varchar(50) NOT NULL,
    email varchar(100) UNIQUE
);

INSERT INTO practice_student (first_name, email)
VALUES ('Dara', 'dara@example.com'), ('Sokha', 'sokha@example.com');

SELECT * FROM practice_student;
UPDATE practice_student SET first_name = 'Dara Updated' WHERE student_id = 1;
DELETE FROM practice_student WHERE student_id = 2;
SELECT * FROM practice_student;
\q
```

The temporary table disappears when you disconnect. This is CRUD: Create, Read, Update, Delete.

## Learn in this order

1. `CREATE TABLE`, data types, and `INSERT`
2. `SELECT`, `WHERE`, `ORDER BY`, and `LIMIT`
3. `UPDATE` and `DELETE` with a careful `WHERE` clause
4. Primary keys and constraints
5. Two tables connected by a foreign key
6. `JOIN`
7. `GROUP BY`, `COUNT`, and `AVG`
8. Transactions: `BEGIN`, `COMMIT`, and `ROLLBACK`
9. The complete grade-management schema and role exercises

When you can explain the temporary-table example without copying it, begin Week 1 in `learning-roadmap.md`.
