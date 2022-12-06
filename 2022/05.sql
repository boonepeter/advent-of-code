CREATE TEMP FUNCTION move_box(directions ARRAY<STRUCT<quantity INT64, move_from INT64, move_to INT64>>, start_positions ARRAY<STRUCT<c INT64, value STRING>>)
RETURNS STRING
LANGUAGE js
AS r"""
  let x = {};
  for (let i = 0; i < start_positions.length; i++) {
    const item = start_positions[i];
    if (!(item.c in x)) {
      x[item.c] = [item.value]
    } else {
      x[item.c].push(item.value)
    }
  }

  for (let i = 0; i < directions.length; i++) {
    const item = directions[i];

    const values = x[item.move_from - 1].slice(-item.quantity);
    // comment out for part 2
    //values.reverse();
    x[item.move_from - 1] = x[item.move_from - 1].slice(0, -item.quantity)
    for (let j = 0; j < values.length; j++) {
      x[item.move_to - 1].push(values[j]); 
    }
  }
  return Object.keys(x).map(k => x[k].pop()).join('');
""";

WITH
  raw_input AS (
  SELECT
  """    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2"""
AS raw_text ),
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
), parsed as (
  SELECT *,
    ARRAY(SELECT REGEXP_EXTRACT(r, r'.(.).') FROM UNNEST(REGEXP_EXTRACT_ALL(raw_row, r'   |\[\w\]')) r ) AS boxes,
    raw_row like '%[%' AS has_box,
    IF(raw_row like 'move%', REGEXP_EXTRACT_ALL(raw_row, r'\d+'), []) AS directions
  FROM raw_rows
), 
split_input AS (
  SELECT
    TO_CODE_POINTS(raw_row) s,
    o as r,
    raw_row
  FROM raw_rows
  WHERE raw_row LIKE '%[%'
),
grouped_in AS (
  SELECT
    CHR(i) as char,
    o,
    r,
    raw_row
  FROM split_input,
  UNNEST(s) i WITH OFFSET o
),
grouped_input AS (
  SELECT
    STRING_AGG(char, '') OVER (PARTITION BY DIV(o, 4), r ORDER BY r, o) box,
    o,
    r
  FROM grouped_in    
),
final_boxes AS (
  select o, r, REGEXP_EXTRACT(box, r'\w') as box
  from grouped_input
  WHERE MOD(o, 4) = 2
),
directions as (
  SELECT
    STRUCT(
      CAST(directions[OFFSET(0)] AS INT) as quantity,
      CAST(directions[OFFSET(1)] AS INT) as move_from,
      CAST(directions[OFFSET(2)] AS INT) AS move_to
    ) AS direction
  FROM parsed
  WHERE ARRAY_LENGTH(directions) > 0
),
box_rows AS (
  SELECT
    box,
    DIV(o, 4) AS c,
    r
  FROM final_boxes

  -- SELECT
  --   box, o as r, c
  -- FROM parsed,
  -- UNNEST(boxes) box WITH OFFSET c
  -- WHERE has_box
  -- ORDER BY o DESC
), box_columns AS (
  SELECT
    box as value,
    c
  FROM box_rows
  WHERE box <> ' '
  ORDER BY c, r DESC
), box_arrays AS (
  SELECT
    ARRAY_AGG(
      STRUCT(
        c,
        value
      )
    ) AS boxes
  FROM box_columns
), array_directions AS (
  SELECT ARRAY_AGG(direction) directions
  FROM directions
)
SELECT 
  move_box(directions, boxes)
FROM array_directions
JOIN box_arrays
ON TRUE
