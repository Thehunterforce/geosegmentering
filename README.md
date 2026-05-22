# NearbyShopsDemo

Pure T-SQL demo of haversine-based nearby shop matching with incremental processing.

## Files – run in order

| File | Purpose |
|---|---|
| `01_schema.sql` | Create all tables |
| `02_seed_data.sql` | Insert 5 sample customers & 10 shops |
| `03_stored_procedures.sql` | `fn_Haversine`, `usp_NearbyShops_FullLoad`, `usp_NearbyShops_Incremental` |
| `04_demo_run.sql` | Step-by-step demo with result queries |

## How to run

1. Open a new database in **SQL Server Management Studio** or **Azure Data Studio**
2. Run each `.sql` file in order
3. Step through `04_demo_run.sql` section by section to see results

## Incremental strategy

| Scenario | Comparisons |
|---|---|
| Full load: 500K customers × 60K shops | 30 billion — run **once** |
| Daily: 10 new shops × 500K customers | 5 million ✅ |
| Daily: 100 new customers × 60K shops | 6 million ✅ |

The `IsProcessed` flag on both `Shop` and `CustomerLocation` ensures pairs are never re-evaluated.
