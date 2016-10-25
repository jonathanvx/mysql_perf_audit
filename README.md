# mysql_perf_audit

This is a bash script that gathers data about your MySQL system for the purpose of carrying out a **Performance Audit**.
Currently, this script expects:
* You are running this on the MySQL database server
* You have a .my.cnf file for your host/user/password set in the home directory of the user you are logging on to the linux OS
* You have downloaded pt-query-diget, pt-summary and pt-mysql-summary from: wget percona.com/get/pt-query-digest
* That this pt tools have been ```chmod a+x pt-*```
