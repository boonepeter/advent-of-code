WITH
  raw_input AS (
  SELECT
    """vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw""" AS raw_text ),
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
common_letters as (
  SELECT
    *,
    TO_CODE_POINTS((
      (SELECT * FROM UNNEST(SPLIT(SUBSTR(raw_row, 0, DIV(LENGTH(raw_row), 2)), '')))
        INTERSECT DISTINCT
      (SELECT * FROM UNNEST(SPLIT(SUBSTR(raw_row, DIV(LENGTH(raw_row), 2) + 1), '')))
    ))[OFFSET(0)] - 64 as code_point,
  FROM raw_rows
),
part_1 AS (
  SELECT
    SUM(IF(code_point < 27, code_point + 26, code_point - 32))
  FROM common_letters
),
group_of_three as (
  SELECT 
    LAG(raw_row, 2) OVER (ORDER BY o) as lag_2,
    LAG(raw_row) OVER (ORDER BY o) as lag_1,
    *,
  FROM raw_rows
),
common_three AS (
  SELECT
    TO_CODE_POINTS((
      (SELECT * FROM UNNEST(SPLIT(lag_2, '')))
      INTERSECT DISTINCT
      (SELECT * FROM UNNEST(SPLIT(lag_1, '')))
      INTERSECT DISTINCT
      (SELECT * FROM UNNEST(SPLIT(raw_row, '')))
    ))[OFFSET(0)] - 64 AS code_point,
    *
  FROM group_of_three
  WHERE MOD(o, 3) = 2
),
part_2 as (
  SELECT
    SUM(IF(code_point < 27, code_point + 26, code_point - 32))
  FROM common_three
)
SELECT *
FROM part_2;