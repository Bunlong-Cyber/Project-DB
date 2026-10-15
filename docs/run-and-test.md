# Run and test guide

## Recommended: private local lab

From the project directory:

```bash
./scripts/start-lab.sh
./scripts/run-tests.sh
```

The revised grade-management lab lives under `~/.local/share/scms-grade-pg-lab` and does not modify the system PostgreSQL cluster. It uses a separate directory so an older SCMS learning database is left untouched. Normal starts preserve data. Stop the lab with `./scripts/stop-lab.sh`. Read the script before using `./scripts/reset-lab.sh`; reset deliberately removes this revised lab database.

The lab is for fictional learning data only. Never put real student information or real passwords in it.

## Optional Docker setup

If Docker is installed, see the commands in `README.md` and inspect `docker-compose.yml` before starting it. The service binds to localhost. Initialization SQL runs only when its named volume is first created; removing that volume deletes its database data.

## Build the reference database manually

Use a new, disposable database and run from the project directory:

```bash
createdb scms_reference
psql -d scms_reference -v ON_ERROR_STOP=1 -f sql/reference/01_schema.sql
psql -d scms_reference -v ON_ERROR_STOP=1 -f sql/reference/02_seed.sql
psql -d scms_reference -v ON_ERROR_STOP=1 -f sql/reference/03_reports.sql
psql -d scms_reference -v ON_ERROR_STOP=1 -f sql/reference/04_security.sql
psql -d scms_reference -v ON_ERROR_STOP=1 -f tests/01_integrity_checks.sql
psql -d scms_reference -v ON_ERROR_STOP=1 -f tests/02_security_checks.sql
```

Expected sample counts are documented in `tests/01_integrity_checks.sql`. Invalid-data demonstrations intentionally show errors, then roll them back; those expected errors mean the database rules worked.

## Security exercise warning

The scripts create PostgreSQL group roles and row-level security policies in this disposable lab. The `app.student_id` and `app.teacher_id` settings are test context, not trustworthy authentication. A real application must set identity through a trusted server-side connection and needs additional security review.

Do not run these scripts against a production/shared database. Use `dropdb scms_reference` only after confirming you no longer need that disposable database. Complete your own starter files in a separate database and compare decisions with `sql/reference/` afterward.
