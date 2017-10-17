SELECT wlm.query AS query_id,
       wlm.state,
       wlm.service_class AS queue,
       CONVERT_TIMEZONE('Asia/Calcutta',wlm.wlm_start_time) AS starttime,
       wlm.slot_count,
       pg_user.usename AS username,
       ex.inner_bcast_count,
       bcast.bcast_rows,
       CAST((wlm.exec_time) AS float) / 1000000 AS exec_time,
       CAST((wlm.queue_time) AS float) / 1000000 AS queue_time,
       CAST(SUM(qs.workmem) AS float) / 1000000000 AS workmem,
       SUM(CASE WHEN qs.is_diskbased = 't' THEN 1 ELSE 0 END) AS num_diskhits
       FROM stv_wlm_query_state wlm
        LEFT JOIN svv_query_state qs ON qs.query = wlm.query
        LEFT JOIN pg_user ON qs.userid = pg_user.usesysid
        LEFT JOIN (SELECT DISTINCT query, 
                       SUM(ROWS) AS bcast_rows
                   FROM stl_bcast
                   GROUP BY 1) bcast ON bcast.query = wlm.query
        LEFT JOIN (SELECT DISTINCT ex.query,
                   COUNT(*) inner_bcast_count
                   FROM stl_explain ex,
                   stv_wlm_query_state wlm
                   WHERE wlm.query = ex.query
                   AND   wlm.state = 'Running'
                   AND   ex.plannode LIKE ('%%DS_BCAST_INNER%%')
                   GROUP BY 1) ex ON ex.query = wlm.query
GROUP BY 1,
 2,
 3,
 4,
 5,
 6,
 7,
 8,
 9,
 10
