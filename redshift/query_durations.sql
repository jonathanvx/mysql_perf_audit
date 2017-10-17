WITH
durations1 AS (
  SELECT
    TRIM("database") AS db,
    TRIM(u.usename) AS "user",
    TRIM(label) AS query_group,
    DATE_TRUNC('day', starttime) AS day,
    -- total_queue_time/1000000.0 AS duration,
    -- total_exec_time/1000000.0 AS duration,
    (total_queue_time + total_exec_time)/1000000.0 AS duration
  FROM stl_query q, stl_wlm_query w, pg_user u
  WHERE q.query = w.query
    AND q.userid = u.usesysid
    AND aborted = 0
),
durations2 AS (
  SELECT
    db,
    "user",
    query_group,
    day,
    duration,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY duration) OVER (PARTITION BY db, "user", query_group, day) AS median,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY duration) OVER (PARTITION BY db, "user", query_group, day) AS p75,
    PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY duration) OVER (PARTITION BY db, "user", query_group, day) AS p90,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY duration) OVER (PARTITION BY db, "user", query_group, day) AS p95,
    PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY duration) OVER (PARTITION BY db, "user", query_group, day) AS p99,
    PERCENTILE_CONT(0.999) WITHIN GROUP (ORDER BY duration) OVER (PARTITION BY db, "user", query_group, day) AS p999
  FROM durations1
)
SELECT
  db,
  "user",
  query_group,
  day,
  MIN(duration) AS min,
  AVG(duration) AS avg,
  MAX(median) AS median,
  MAX(p75) AS p75,
  MAX(p90) AS p90,
  MAX(p95) AS p95,
  MAX(p99) AS p99,
  MAX(p999) AS p999,
  MAX(duration) AS max
FROM durations2
GROUP BY 1, 2, 3, 4
ORDER BY 1, 2, 3, 4;
