# mysql_perf_audit

This is a bash script that gathers data about your MySQL system for the purpose of carrying out a **Performance Audit**.
Currently, this script expects:
* You are running this on the MySQL database server
* You have a .my.cnf file for your host/user/password set in the home directory of the user you are logging on to the linux OS
* You have downloaded pt-query-diget, pt-summary and pt-mysql-summary from: ```wget percona.com/get/pt-query-digest```
* That this pt tools have been ```chmod a+x pt-*```

Query Digest processes MySQL database logs and gives out a report.
The range of queries recorded in the logs, the quality and relevance of those queries and the length of time that those queries have been recorded effects the quality of the report.

It is advised that you take a period of 6-12 hours where you record all your queries to the slow log.
In order to do that, set the following variable inside the MySQL shell:
```set global long_query_time=0; set long_query_time=0; flush logs;```

You should make sure that the slow query file exists and is being written to 
and ideally, empty it out by using ```echo "" >/path/your/slow.log``` before starting.

