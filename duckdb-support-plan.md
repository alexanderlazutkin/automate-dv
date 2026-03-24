# Актуализированный план/статус поддержки DuckDB в automate-dv

## 1) Текущее состояние (по факту репозитория)

Поддержка DuckDB в пакете `automate-dv` уже реализована и используется через adapter dispatch (`duckdb__*`).

### Что уже есть в `automate-dv`

- Табличные макросы DuckDB в `macros/tables/duckdb/`:
  - `hub.sql`, `link.sql`, `eff_link.sql`, `sat.sql`, `eff_sat.sql`, `ma_sat.sql`, `nh_link.sql`, `pit.sql`, `bridge.sql`, `ref_table.sql`, `xts.sql`.
- Supporting-макросы DuckDB:
  - типы: `type_binary`, `type_string`, `type_timestamp`;
  - hash/null: `hash_alg_md5`, `hash_alg_sha256`, `hash_alg_sha1`, `null_expression`;
  - casting: `cast_binary`, `cast_date`, `cast_datetime`;
  - ghost/max: `date_ghost`, `max_datetime`.
- Helper/metadata макросы DuckDB:
  - `dateadd`, `timestamp_add`, `get_escape_characters`.

### Тестовый контур

- Есть smoke-тест dispatch: `automate-dv/tests/duckdb_dispatch_smoke_test.sql`.
- Есть документ со сценарием тестирования и acceptance-критериями: `automate-dv/tests/duckdb_test_scenarios.md`.

### Подтверждение в документации

- В `automate-dv/README.md` явно указано наличие DuckDB adapter-dispatched макросов.

---

## 2) Изменение статуса плана

Исторический план «добавить поддержку DuckDB» считается **выполненным в базовой части реализации**.

Что изменилось относительно старого плана:

1. Не «создать» DuckDB-ветки, а поддерживать и расширять уже существующие.
2. Фокус смещается с первичной разработки на:
   - стабильность;
   - регрессионное покрытие;
   - CI-автоматизацию;
   - контроль совместимости при изменениях в базовых макросах.

---

## 3) Открытые задачи (актуальные)

### 3.1 Тесты

1. Разнести smoke в отдельный `schema.yml`-набор generic tests.
2. Добавить фикстуры с expected-таблицами и equality-сравнение.
3. Покрыть edge-cases:
   - `NULL` / пустые строки;
   - повторные загрузки без дельты;
   - инкремент с новой версией hashdiff;
   - режимы `enable_native_hashes=true/false`.

### 3.2 CI/CD

1. Добавить отдельный CI job под DuckDB (`dbt deps/seed/run/test`).
2. Зафиксировать минимальный smoke gate в обязательных проверках PR.

### 3.3 Документация

1. Отразить матрицу покрытия по макросам (table/supporting/helper).
2. Документировать known limitations и различия по типам/кастам.

---

## 4) Риски сопровождения

1. **Дрифт логики** между адаптерами при изменениях базовых макросов.
2. **Недостаточное тестовое покрытие** для edge-сценариев.
3. **Регрессии производительности** на крупных наборах данных без CI-бенчмарков.

---

## 5) Рекомендуемый план работ (короткий backlog)

1. **P0**: добавить CI workflow для DuckDB + обязательный smoke.
2. **P0**: добавить regression-набор данных и equality-тесты.
3. **P1**: расширить документацию по supported behavior и ограничениям.
4. **P1**: ввести периодический review DuckDB-веток при изменениях в общих макросах.

---

## 6) Критерий актуальности этого документа

Документ актуален, пока:

- каталог `automate-dv/macros/tables/duckdb/` содержит полный набор реализованных макросов;
- в supporting/helper слоях присутствуют `duckdb__`-ветки;
- smoke/сценарные тестовые артефакты находятся в `automate-dv/tests/`.
