SELECT DISTINCT m_u.user, m_u.host
  FROM mysql.user m_u
  LEFT JOIN performance_schema.accounts ps_a ON m_u.user = ps_a.user AND m_u.host = ps_a.host
 WHERE ps_a.user IS NULL
ORDER BY m_u.user
;
