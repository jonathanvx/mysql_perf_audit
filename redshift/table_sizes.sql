SELECT t.name, COUNT(tbl) / 1000.0 AS gb
FROM (
  SELECT DISTINCT datname, id, name
  FROM stv_tbl_perm
  JOIN pg_database ON pg_database.oid = db_id
) AS t
JOIN stv_blocklist ON tbl = t.id
GROUP BY t.name ORDER BY gb DESC;
