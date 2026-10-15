# Student Academic Grade Management System

A beginner-friendly PostgreSQL project for a fictional high school. Students view their own subject grades by academic year and Grade 10–12 level; teachers manage grades only for their assigned subjects; administrators manage academic records, accounts, roles, and permissions.

This is a **database learning project**, not a website or production login system. It uses fictional data and does not include attendance, payments, online classes, or class scheduling.

## Start here

1. Read [`docs/project-brief.md`](docs/project-brief.md) for the purpose, users, scope, and assumptions.
2. Work through [`docs/team-design-workshop.md`](docs/team-design-workshop.md) to practice entities, attributes, and keys.
3. Study [`docs/erd.md`](docs/erd.md) and explain each relationship in your own words.
4. If new to PostgreSQL, start with [`docs/00-before-postgresql.md`](docs/00-before-postgresql.md).
5. Follow [`docs/learning-roadmap.md`](docs/learning-roadmap.md) and complete starter SQL before using the reference implementation.

## Project contents

```text
docs/       project brief, beginner design workshop, ERD, roadmap, run guide
sql/        starter exercises and a complete explained reference implementation
tests/      integrity and permission demonstrations
scripts/    start, test, reset, and stop a private local PostgreSQL lab
```

## Run the local lab

On the configured Ubuntu machine, from this project directory:

```bash
./scripts/start-lab.sh
./scripts/run-tests.sh
```

The scripts use a private local PostgreSQL cluster and fictional seed records. Read [`docs/run-and-test.md`](docs/run-and-test.md) before resetting data or running the optional Docker setup. Never use production or real student data.

## Version-one design assumptions

- One student grade-level record per academic year.
- One responsible teacher for a subject/grade-level/academic-year combination.
- One final numeric score (0–100) for each student/subject/year/grade combination.
- If the school needs multiple classes or teachers for the same subject and grade, add and review a class/section design before implementing it.

The reference SQL is a worked example for comparison, not a substitute for building the starter yourself.
