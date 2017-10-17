SELECT DISTINCT t.table_schema, t.table_name
  FROM information_schema.tables AS t
  LEFT JOIN information_schema.columns AS c ON t.table_schema = c.table_schema AND t.table_name = c.table_name AND c.column_key = "PRI"
 WHERE t.table_schema NOT IN ('information_schema', 'mysql', 'performance_schema')
   AND c.table_name IS NULL AND t.table_type != 'VIEW'
;
