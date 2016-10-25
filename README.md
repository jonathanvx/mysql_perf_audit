# mysql_perf_audit

This is a bash script that gathers data about your MySQL system for the purpose of carrying out a **Performance Audit**.
Currently, this script expects:
* You are running this on the MySQL database server
* You have a .my.cnf file for your host/user/password set in the home directory for the user on your linux server
* You have downloaded pt-query-diget, pt-summary and pt-mysql-summary from: ```wget percona.com/get/pt-query-digest```
* That these pt tools have been ```chmod a+x pt-*``` as well as ```chmod a+x digest.sh```

Query Digest processes MySQL database logs and gives out a report.
The range of queries recorded in the logs, the quality and relevance of those queries and the length of time that those queries have been recorded effects the quality of the report.

It is advised that you take a period of 6-12 hours where you record all your queries to the slow log.
In order to do that, set the following variable inside the MySQL shell:
```set global long_query_time=0; set long_query_time=0; set global min_examined_row_limit=1; set min_examined_row_limit=1; flush logs;```

You should make sure that the slow query file exists, is being written to 
and ideally, empty it out by using ```echo "" >/path/your/slow.log``` before starting.

Keep an eye on the space available on the directory where the slow log is on and make sure that it is in no way going to reach the space limit - otherwise, your MySQL server may crash.
After 6-12 hours or until your slow log is of 1Gb of size, stop the recording by setting the long_query_time back to what it was before and min_examined_row_limit as well.

Then run ```./digest.sh /path/your/slow.log``` and wait for it to complete.

It should create a series of .txt files which are the foundation of the Performance Audit.
