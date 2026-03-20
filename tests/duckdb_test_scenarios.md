# Сценарий тестирования поддержки DuckDB

## 1) Цель

Подтвердить, что DuckDB-реализации макросов в [`automate-dv/macros/tables/duckdb/`](automate-dv/macros/tables/duckdb) и supporting/helper-макросы корректно работают при типичных Data Vault нагрузках.

---

## 2) Обязательные уровни тестов

### A. Smoke/dispatch тесты

- Проверка, что вызываются именно `duckdb__`-ветки (`adapter.dispatch`).
- Базовый тест уже добавлен: [`automate-dv/tests/duckdb_dispatch_smoke_test.sql`](automate-dv/tests/duckdb_dispatch_smoke_test.sql).

**Критерий успеха:** запрос возвращает 0 строк (нет `NULL` в критичных выражениях).

### B. Функциональные тесты supporting/helper-макросов

Покрыть:
- типы: [`automate-dv/macros/supporting/data_types/type_binary.sql`](automate-dv/macros/supporting/data_types/type_binary.sql), [`automate-dv/macros/supporting/data_types/type_timestamp.sql`](automate-dv/macros/supporting/data_types/type_timestamp.sql)
- касты: [`automate-dv/macros/supporting/casting/cast_date.sql`](automate-dv/macros/supporting/casting/cast_date.sql), [`automate-dv/macros/supporting/casting/cast_datetime.sql`](automate-dv/macros/supporting/casting/cast_datetime.sql)
- hash/null handling: [`automate-dv/macros/supporting/hash_components/select_hash_alg.sql`](automate-dv/macros/supporting/hash_components/select_hash_alg.sql), [`automate-dv/macros/supporting/hash_components/null_expression.sql`](automate-dv/macros/supporting/hash_components/null_expression.sql)
- helper date arithmetic: [`automate-dv/macros/internal/helpers/dateadd.sql`](automate-dv/macros/internal/helpers/dateadd.sql), [`automate-dv/macros/internal/helpers/timestamp_add.sql`](automate-dv/macros/internal/helpers/timestamp_add.sql)

**Критерий успеха:**
- значения соответствуют ожидаемым,
- нет ошибок приведения типов,
- hash длина и формат стабильны.

### C. Интеграционные тесты табличных макросов

Для каждого макроса из [`automate-dv/macros/tables/duckdb/`](automate-dv/macros/tables/duckdb):
- [`duckdb__hub()`](automate-dv/macros/tables/duckdb/hub.sql:6)
- [`duckdb__link()`](automate-dv/macros/tables/duckdb/link.sql:6)
- [`duckdb__sat()`](automate-dv/macros/tables/duckdb/sat.sql:6)
- [`duckdb__eff_sat()`](automate-dv/macros/tables/duckdb/eff_sat.sql:6)
- [`duckdb__ma_sat()`](automate-dv/macros/tables/duckdb/ma_sat.sql:6)
- [`duckdb__nh_link()`](automate-dv/macros/tables/duckdb/nh_link.sql:6)
- [`duckdb__pit()`](automate-dv/macros/tables/duckdb/pit.sql:6)
- [`duckdb__bridge()`](automate-dv/macros/tables/duckdb/bridge.sql:6)
- [`duckdb__ref_table()`](automate-dv/macros/tables/duckdb/ref_table.sql:6)
- [`duckdb__xts()`](automate-dv/macros/tables/duckdb/xts.sql:6)

**Критерий успеха:**
- корректное количество строк,
- корректная дедупликация,
- корректная инкрементальная загрузка,
- соблюдение бизнес-ключей/hashdiff.

---

## 3) Рекомендуемый end-to-end сценарий

### Шаг 1. Подготовка профиля DuckDB

Создать target `duckdb` в `profiles.yml` (локальный файл БД, например `./target/automate_dv.duckdb`).

### Шаг 2. Запустить smoke-тест

```bash
dbt test --target duckdb --select duckdb_dispatch_smoke_test
```

### Шаг 3. Прогон «с нуля»

```bash
dbt seed --target duckdb
dbt run  --target duckdb
dbt test --target duckdb
```

### Шаг 4. Прогон инкрементального сценария

1. Добавить новую порцию seed-данных (новые PK, новые версии hashdiff).
2. Повторно выполнить:

```bash
dbt run  --target duckdb
dbt test --target duckdb
```

Проверить:
- новые версии SAT вставлены,
- дубликаты не создаются,
- PIT/Bridge отражают новые состояния.

### Шаг 5. Негативные/краевые кейсы

- `NULL` в payload и ключах,
- пустые строки,
- одинаковый PK и разный `src_ldts`,
- смена `hash` (`md5` / `sha` / `sha1`),
- `enable_native_hashes=true/false`.

---

## 4) Минимальный набор проверок (acceptance)

1. Все модели компилируются на DuckDB без SQL-ошибок.
2. Все тесты проходят (`dbt test` без fail/error).
3. Row count совпадает с ожидаемым для Hub/Link/Sat после full-refresh.
4. Повторный `dbt run` без новых данных не меняет row count.
5. Инкремент с новыми данными добавляет только новые/измененные записи.

---

## 5) Что добавить следующим шагом

- Разнести текущий smoke в отдельный `schema.yml`-набор generic tests.
- Добавить фикстуры с «эталонными» expected-таблицами и сравнение через equality-тест.
- Добавить CI-job `duckdb` (отдельный workflow) с последовательностью `dbt seed/run/test`.

