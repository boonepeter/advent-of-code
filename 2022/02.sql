WITH
  raw_input AS (
  SELECT
    """A Y
B X
C Z""" AS raw_text ),
  raw_rows AS (
    SELECT
      o,
      TO_CODE_POINTS(raw_row)[OFFSET(0)] - 64 AS opponent,
      TO_CODE_POINTS(raw_row)[OFFSET(2)] - 87 AS me,
      raw_row
    FROM (
      SELECT
        SPLIT(raw_text, '\n') raw_row_array
      FROM
        raw_input ),
      UNNEST(raw_row_array) raw_row WITH OFFSET o
  ),

  round_results_1 AS (
    SELECT
      CASE
        WHEN opponent = me THEN 3
        WHEN me - opponent IN (1, -2) THEN 6
      ELSE 0
    END AS my_result,
      *
    FROM
      raw_rows ),

  part_1 AS (
    SELECT
      SUM(me + my_result)
    FROM
      round_results_1 ),

  round_results_2 AS (
    SELECT
      CASE
        WHEN me = 2 THEN opponent
        WHEN me = 3 THEN MOD(opponent, 3) + 1
        WHEN me = 1 THEN MOD(opponent + 4, 3) + 1
      ELSE 0
    END AS my_pick,
      *
    FROM
      raw_rows ),

  part_2 AS (
    SELECT
      SUM((me - 1) * 3 + my_pick)
    FROM
      round_results_2 )
SELECT
  *
FROM
  part_2;