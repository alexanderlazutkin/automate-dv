-- Smoke test for DuckDB adapter dispatch coverage in supporting/helper macros.
-- Test passes when query returns zero rows.

with smoke as (
    select
        DATE '1900-01-01' as casted_date,
        TIMESTAMP '1900-01-01 00:00:00' as casted_ts,
        {{ automate_dv.cast_binary('FF', quote=true) }} as casted_bin,
        {{ automate_dv.timestamp_add('second', 1, "TIMESTAMP '1900-01-01 00:00:00'") }} as ts_plus,
        coalesce(
            try_cast('{{ automate_dv.max_datetime() }}' as timestamp),
            timestamp '9999-12-31 23:59:59.999999'
        ) as max_dt
)

select 1
from smoke
where casted_date is null
   or casted_ts is null
   or casted_bin is null
   or ts_plus is null
   or max_dt is null
