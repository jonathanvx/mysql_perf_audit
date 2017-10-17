SELECT
  recents.pid,
  TRIM(db_name) AS db,
  TRIM(user_name) AS "user",
  TRIM(label) AS query_group,
  recents.starttime AS start_time,
  recents.duration,
  recents.query AS sql,
  TRIM(remotehost) AS remote_host,
  TRIM(remoteport) AS remote_port
FROM stv_recents recents
LEFT JOIN stl_connection_log connections ON (recents.pid = connections.pid)
LEFT JOIN stv_inflight inflight ON recents.pid = inflight.pid
WHERE TRIM(status) = 'Running'
AND event = 'initiating session';
