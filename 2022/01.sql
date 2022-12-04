WITH
  raw_input AS (
  SELECT
    """1000
2000
3000

4000

5000
6000

7000
8000
9000

10000""" AS raw_text ),
raw_rows AS (
  SELECT
    o,
    raw_row
  FROM (
    SELECT
      SPLIT(raw_text, '\n') raw_row_array
    FROM
      raw_input ),
    UNNEST(raw_row_array) raw_row WITH OFFSET o
),
elf_ids AS (
  SELECT
    COUNTIF(raw_row = '') OVER (ORDER BY o) AS elf_id,
    o,
    CAST(IF(raw_row = '', '0', raw_row) AS INT) AS calories
  FROM raw_rows
),
part_1 AS (
  SELECT
    SUM(calories),
    elf_id
  FROM
    elf_ids
  GROUP BY elf_id
  ORDER BY SUM(calories) DESC
  LIMIT 1
),
top_elves AS (
SELECT
  SUM(calories) calorie_sum,
  elf_id
FROM
  elf_ids
GROUP BY elf_id
ORDER BY SUM(calories) DESC
LIMIT 3
)
-- Part 2
SELECT
  SUM(calorie_sum) total_calories
FROM top_elves;
