# Alioth

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14%2B-336791.svg)](https://www.postgresql.org/)
[![简体中文](https://img.shields.io/badge/README-%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87-blue.svg)](README.zh-CN.md)

A **PostgreSQL table-inherited data model** grounded in group theory and commutative ontology. Alioth formalizes economic behavior as symmetric operations within a 4-dimensional orthogonal space `(Scene, Factor, Function, State)`, providing a mathematically rigorous foundation for enterprise data management.

Latest model version is anchored at [`latest.json`](latest.json).

---

## Repository Layout

Published models are stored **per version** in this repository. Each publish writes a versioned directory `v{major}.{minor}.{patch}/`:

```
Alioth/
├── latest.json                     # Latest version anchor: version, published_at, seed table row counts, file list
└── v10.0.5/                       # One directory per released version (SemVer)
    ├── 001_schema.sql              # CREATE SCHEMA IF NOT EXISTS isahl
    ├── 002_isahl_tables.sql        # isahl schema structure only (pure CREATE/ALTER, post-processed)
    ├── 003_seed_dimensions.sql     # Seed data for 11 dimension/consensus/system-settings tables
    ├── 003_seed_dimensions.meta.json  # Expected row counts per seed table (for verification)
    └── README.md                   # Per-version readme (export timestamp, pg_dump version)
```

---

## Quick Start

### Prerequisites

- PostgreSQL 14+
- The `isahl_meta` type definitions referenced by `isahl` columns must exist (enums/domains are injected from the source database during verification; a standard deployment ships them together with the schema).

### Setup

```bash
git clone https://github.com/CosmicTools9/Alioth.git
cd Alioth
VERSION=$(jq -r .version latest.json)   # or pick a concrete version directory
psql "$DATABASE_URL" -f "$VERSION/001_schema.sql"
psql "$DATABASE_URL" -f "$VERSION/002_isahl_tables.sql"
psql "$DATABASE_URL" -f "$VERSION/003_seed_dimensions.sql"
```

The three files must be applied **in order**: schema → tables → seed data.

### Verification

```sql
-- Abstract type layer
SELECT relname FROM pg_class WHERE relname LIKE 'zc_ad_%' AND relkind = 'r' ORDER BY 1;

-- Business objects count
SELECT count(*) FROM pg_class WHERE relname LIKE 'zc_id_%' AND relkind = 'r';

-- Seed dimensions loaded
SELECT code, notice FROM isahl.zc_id_scene LIMIT 10;
```

---

## Model Architecture

### Inheritance Hierarchy

Alioth uses PostgreSQL table inheritance to build a layered hierarchy from abstract mathematical types to concrete business objects. Table name prefixes: `zc` (project prefix), `ad` = **abstract data**, `id` = **implement data**.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'primaryColor': '#e8f4fc'}}}%%
graph TD
    subgraph Abstract Layer[zc_ad_* abstract data]
        AD[zc_ad_object] --> V[zc_ad_variable]
        V --> Vec[zc_ad_vector]
        V --> Sca[zc_ad_scalar]
        V --> Ten[zc_ad_tensor]
        Vec --> Dim[zc_ad_dimension]
        Vec --> Rel[zc_ad_relation]
    end

    subgraph Implement Layer[zc_id_* implement data]
        AD --> IDO[zc_id_object]
        IDO --> Entity[zc_id_entity]
        IDO --> Stat[zc_id_status]
        IDO --> Prod[zc_id_product]
        Ten --> LC[zc_id_lifecycle]
        LC --> IDO
        LC --> Evt[zc_id_event]
        LC --> Agr[zc_id_agreement]
        Evt --> Apv[zc_id_approve]
    end

    style AD fill:#e8f4fc,stroke:#333,stroke-width:2px
    style IDO fill:#c8e6c9,stroke:#333,stroke-width:2px
    style LC fill:#fff9c4,stroke:#333,stroke-width:2px
```

| Layer | Prefix | Root Table | Role | Field Characteristics |
|---|---|---|---|---|
| L0 Abstract | `zc_ad_` | `zc_ad_object` | Root of all objects | `id`, `created_at`, `updated_at` |
| L1 Semantic | `zc_ad_` | `zc_ad_variable` | Adds semantic identity | `code`, `notice`, `unit` |
| L2 Structure | `zc_ad_` | `zc_ad_scalar` / `zc_ad_vector` / `zc_ad_tensor` / `zc_ad_dimension` | Differentiation by mathematical structure |
| L3 Relation | `zc_ad_` | `zc_ad_relation` | Directed connection between two entities | `ref_left`, `ref_right` |
| L4 Implement | `zc_id_` | `zc_id_object` | **Business element root** — first-order inheritance defines categorical implementations |
| L5 Lifecycle | `zc_id_` | `zc_id_lifecycle` | Lifecycle trajectory for objects | `no`, `op_seq` |
| L6+ Leaf | `zc_id_` | `zc_id_order`, `zc_id_order-shipping`, … | Concrete business scenarios | All inherited fields + business-specific columns |

### 3D Coordinate System

Every lifecycle entity occupies a unique coordinate `(Scene, Factor, Function)` in the `isahl` space — all three dimensions are **fully orthogonal**:

| Dimension | DB Column | References | Meaning |
|---|---|---|---|
| Scene | `dk_scene` | `zc_id_scene` | Business context of the exchange (*where* the transaction occurs) |
| Factor | `dk_factor` | `zc_id_factor` | Subjects/mediums/objects participating in the exchange (*who* trades *what*) |
| Function | `dk_function` | `zc_id_function` | Operations at different stages and levels of the exchange (*how* the trade works) |

All three dimension bases inherit from `zc_ad_dimension`. Each dimension's `code` is auto-concatenated from a **category prefix + sequence symbol** (e.g., `JC` = system management), generated by triggers on INSERT/UPDATE.

### Five-Domain Completeness (LCGPF)

The Factor dimension is divided into five domains corresponding to the five indispensable perspectives of any complete exchange:

| Code | Domain | Elements | Economic Role |
|---|---|---|---|
| L | Labor | Participant subgroup | Who trades |
| C | Container | Medium/container subgroup | What carries value |
| G | Goods | Subject-matter subgroup | What is traded |
| P | Place | Location subgroup | Where trading |
| F | Finance | Process & information subgroup | How value flows |

Domain membership is classified via `ck_category` → `zc_id_cons-factor-cate.a_type_`. A complete exchange snapshot **must** cover all five domains (no symmetry breaking allowed), enforced by the model inference engine.

### State Expression in Lifecycles

Discrete projections of a business object's lifecycle state are expressed through relation tables:

```
zc_id_lifecycle_r_primary-status → zc_id_status-*     Primary state (monotonic, e.g., born→dead)
zc_id_lifecycle_r_status         → zc_id_status       General state (bidirectional, e.g., active↔on leave)
zc_id_lifecycle_r_tags           → zc_id_tags         Tags
zc_id_lifecycle_r_category       → zc_id_category     Categories
```

---

## Naming Conventions

### Table-Level

| Suffix | Relationship Type | Example |
|---|---|---|
| `{entity}_r_{target}` | One-to-many reference table | `zc_id_lifecycle_r_status` |
| `{entity}_rr_{target}` | Many-to-many bridge table | `zc_id_bom_rr_item` |

Reference tables carry `ref_left` (referencer) and `ref_right` (referenced) columns.

### Column-Level

| Prefix | Meaning | Example |
|---|---|---|
| `qk_*` | Scalar reference key → `zc_id_scalar-*` system | `qk_price`, `qk_amount` |
| `fk_*` | Foreign key reference | `fk_country` |
| `sk_*` | Unit reference | `sk_unit` (points to measurement unit table) |
| `ck_*` | Category/classification reference | `ck_category` |
| `tk_*` | Tag reference | `tk_batch_no` (single-select tag) |
| `lk_*` | Level/grade reference | `lk_level` |

> The `_f_` and `_t_` columns are auto-derived from the `dk_function.code` prefix (six forms: `!.` / `!_` / `↑.` / `↑_` / `↓.` / `↓_` → Creative / Design / Implement × Paradigm / Instance) and are never exposed in business-layer DTOs.

---

## Key Design Decisions

### ID Generation

| Table Type | Function |
|---|---|
| `zc_id_lifecycle` and all its children | `isahl.gen_next_zuid()` — globally unique IDs |
| Non-lifecycle business tables | `isahl.gen_next_uid(table_code)` — deterministic IDs |
| `isahl_meta` metadata tables | `BIGSERIAL` |

Inherited tables bind their own generators via separate `ALTER COLUMN id SET DEFAULT` statements to avoid conflicts in multiple-inheritance scenarios.

### Scalar Reference Model

All measurable continuous quantities (amounts, dates, quantities, prices) are **not stored as native types** on business tables. Instead, they pass through scalar reference tables:

```
business_table.qk_price (bigint) → zc_id_scalar-price.id → zc_id_scalar-price.mark (numeric)
business_table.qk_date  (bigint) → zc_id_scalar-date.id  → zc_id_scalar-date.date  (timestamptz)
```

| Prefix | Scalar Table | Actual Value Column |
|---|---|---|
| `qk_date` | `zc_id_scalar-date` | `date` (timestamptz) |
| `qk_amount` | `zc_id_scalar-amount` | `mark` (numeric) |
| `qk_price` | `zc_id_scalar-price` | `mark` (numeric) |
| `qk_qty` | `zc_id_scalar-common` | `mark` (numeric) |
| Other `qk_*` | `zc_id_scale` inheritance hierarchy | `mark` (numeric) |

**Hard constraint**: All `qk_*` columns are `bigint` in DDL. Never define them as `Decimal`, `DateTime`, or `String` — the actual typed value lives on the referenced scalar row.

### Column Writeability

| Category | Writeability | Typical Columns |
|---|---|---|
| 🚫 System-generated | Invisible & unwritable | `id`, `created_at`, `updated_at`, `deleted_at` |
| 🔒 Dimension/trigger-derived | Not exposed in DTOs | `number`, `domain_`, `_f_`, `_t_`, `dk_*`, `paths` |
| ✅ User-writable | Directly in DTOs | `notice`, `code`, `comments`, `qk_*`, `fk_*`, `ck_*`, `tk_*` |

---

## Model Publishing

Each version directory is produced by the model publishing pipeline:

1. Export the `isahl` schema from the authoritative database via `pg_dump --schema-only` (plus data-only dumps of the 11 seed tables).
2. Post-process to **pure CREATE/ALTER** form: strip runtime-only statements, inline `id` column DEFAULTs are extracted and re-applied as `ALTER TABLE ... ALTER COLUMN id SET DEFAULT isahl.gen_next_uid(...)` statements, ordered topologically by inheritance depth so every inherited table binds its own generator.
3. Write the versioned directory under this repository and update `latest.json`.
4. **Rebuild verification** (non-blocking): on a clean test database, drop `isahl` / `isahl_auth` / `isahl_audit` and re-apply the three SQL files in order with `ON_ERROR_STOP=1`, then assert seed-table row counts and `gen_next_uid` uniqueness (0 conflicts, 0 missing). A passing rebuild marks the version `verified`.

Versioning follows [SemVer](https://semver.org/). Versions never decrease; the floor is `v10.0.0`. Publish records (version, description, output directory, file list, status) are tracked in `isahl_meta.model_publish_records`.

---

## Contributing

The Alioth model evolves through versioned releases. Report DDL compatibility issues or suggest model improvements via [Issues](https://github.com/CosmicTools9/Alioth/issues).

---

## License

[MIT](LICENSE) © 2025-2026 宇器科技(CosmicTools.ltd) & CosmicTools Team

---

**Alioth** — A mathematically-grounded enterprise data ontology

Built with heart by the [CosmicTools](https://cosmic-tools.ltd) team
