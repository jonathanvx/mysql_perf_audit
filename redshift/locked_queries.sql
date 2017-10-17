select relation::regclass, mode, pid from pg_locks where locktype != 'virtualxid' ;
