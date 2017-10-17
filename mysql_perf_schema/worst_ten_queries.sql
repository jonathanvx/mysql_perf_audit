select d.*, (select group_concat(distinct TABLE_NAME) FROM information_schema.TABLES where table_schema = d.schema_name and d.digest_text regexp table_name) table_name
 FROM performance_schema.events_statements_summary_by_digest d
where d.DIGEST_TEXT regexp "^(SELECT|UPDATE|DELETE|REPLACE|INSERT|CREATE)"
and d.LAST_SEEN > curdate() - interval 7 day
order by d.SUM_TIMER_WAIT desc limit 10\G
