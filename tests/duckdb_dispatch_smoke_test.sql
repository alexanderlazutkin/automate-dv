-- Smoke test for DuckDB adapter dispatch coverage in supporting/helper macros.
-- Test passes when query returns zero rows.

with smoke as (
    select
        {{ automate_dv.cast_date('1900-01-01', as_string=true) }} as casted_date,
        {{ automate_dv.cast_datetime('1900-01-01 00:00:00', as_string=true) }} as casted_ts,
        {{ automate_dv.cast_binary('FF', quote=true) }} as casted_bin,
        {{ automate_dv.timestamp_add('second', 1, "CAST('1900-01-01 00:00:00' AS TIMESTAMP)") }} as ts_plus,
        {{ automate_dv.max_datetime() }} as max_dt
)

select 1
from smoke
where casted_date is null
   or casted_ts is null
   or casted_bin is null
   or ts_plus is null
   or max_dt is null

