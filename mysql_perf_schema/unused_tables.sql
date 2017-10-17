SELECT t.table_schema, t.table_name, t.table_rows, tio.count_read, tio.count_write
  FROM information_schema.tables AS t
  JOIN performance_schema.table_io_waits_summary_by_table AS tio
    ON tio.object_schema = t.table_schema AND tio.object_name = t.table_name
 WHERE t.table_schema NOT IN ('mysql', 'information_schema', 'performance_schema', 'sys')
   AND tio.count_write = 0 and tio.count_read=0
 ORDER BY t.table_rows DESC, t.table_schema, t.table_name limit 20;
