# Alioth Model @ v10.0.0

Exported at 2026-08-19T08:06:21.920418+00:00
pg_dump version: pg_dump (PostgreSQL) 18.6 (Homebrew)

## Files

- `001_schema.sql` — Create `isahl` schema.
- `002_isahl_tables.sql` — All tables in `isahl` schema (structure only).
- `003_seed_dimensions.sql` — Seed data for isahl standard model: dimension tables (scene/factor/function), consensus category tables, and system-settings reference tables (status/subjects/category/version/lifecycle).

## Usage

Run the SQL files in order:

```bash
psql $DATABASE_URL -f 001_schema.sql
psql $DATABASE_URL -f 002_isahl_tables.sql
psql $DATABASE_URL -f 003_seed_dimensions.sql
```
