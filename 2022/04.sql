WITH
  raw_input AS (
  SELECT
    """2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8""" AS raw_text ),
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
parsed_rows AS (
  SELECT
    ARRAY(
      SELECT
        CAST(n AS INT)
      FROM
      UNNEST(
        REGEXP_EXTRACT_ALL(raw_row, r'\d+')) n
    ) AS sections,
    *
  FROM raw_rows
),
part_1 as (
  SELECT
    (
      sections[OFFSET(0)] >= sections[OFFSET(2)]
      AND sections[OFFSET(1)] <= sections[OFFSET(3)]
    )
    OR (
      sections[OFFSET(2)] >= sections[OFFSET(0)]
      AND sections[OFFSET(3)] <= sections[OFFSET(1)]
    ) as overlap,
    *
  FROM parsed_rows
),
part_2 AS (
  SELECT
    (
      sections[OFFSET(1)] >= sections[OFFSET(2)]
      AND sections[OFFSET(0)] <= sections[OFFSET(3)]
    )
    AS overlap,
    *
  FROM parsed_rows
)
SELECT 
  COUNTIF(overlap)
FROM part_2;
