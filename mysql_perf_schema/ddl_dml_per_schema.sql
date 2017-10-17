SELECT schema_name, IF(SUBSTRING_INDEX(digest_text, ' ', 1) IN ('CREATE', 'DROP', 'ALTER', 'GRANT', 'REVOKE'), 'DDL', 'DML') AS statement_type, COUNT(*) AS count
  FROM performance_schema.events_statements_summary_by_digest
  INNER JOIN information_schema.SCHEMATA using(schema_name) 
 GROUP BY statement_type, schema_name
 ORDER BY statement_type DESC, count DESC
;
