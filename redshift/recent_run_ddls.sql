SELECT
  starttime,
  xid,
  LISTAGG(text) WITHIN GROUP (ORDER BY sequence) AS sql
FROM stl_ddltext
GROUP BY 1, 2
ORDER BY 1 DESC;
