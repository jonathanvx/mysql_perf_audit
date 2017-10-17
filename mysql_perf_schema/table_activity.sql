SELECT object_type, object_schema, object_name
     , count_star, count_read, count_write, count_fetch
     , count_insert, count_update, count_delete
  FROM performance_schema.table_io_waits_summary_by_table
 WHERE count_star > 0
 ORDER BY count_star DESC
;
