# mysql_perf_audit

This is a bash script that gathers data about your MySQL system for the purpose of carrying out a **Performance Audit**.
Currently, this script expects:
* You are running this on the MySQL database server
* You have a .my.cnf file for your host/user/password set in the home directory for the user on your linux server
* You have downloaded ```pt-query-diget, pt-summary and pt-mysql-summary``` from: ```wget percona.com/get/pt-query-digest```
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


# F.A.Q.
### Why did you set the long_query_time to 0 ?
This makes the slow log file log all the queries with additional details found in the slow log. 
During the time the long_query_time is set to 0, you are getting a good view of what is run on your database which you can later analyse.

### Why did you set the min_examined_row_limit to 1?
This setting is an attempt to clean up the slow logs to hold more relevant set of queries.
What happens often, sometimes with certain blog packages, the slow log gets flooded with with commands like ``SET timestamp=``` for example. This setting helps get queries that have examined at least 1 row from a table. This is what I am interested in, it appears to get relevant information and it keeps the slow log smaller. 

What it does miss is queries where the result was 0 rows and the index was used to determine that no rows were needed to be examined.
While that may change the weight of certain queries in the report, from my experience, this is an acceptable trade-off.


### Will running this script cause load on the server? Is it safe to run?

There a two issues here, IO and CPU usage. The writting to the slow log itself, uses IO. There are large websites that are sensitive about this and use ```tcpdump``` to send the IO to another server. However, the companies that I usually deal with, this is never a problem. It is more common to run out of space while taking the slow log.

The second issue is CPU: ```pt-query-digest``` uses perl and you would see a perl thread take up 100% of a CPU thread if you run ```top```. In 2010-2011, it was common practice to move the slow log to another process and run ```pt-query-digest``` there. However, we now have less of an issue of free threads and this bash script does run things that need to query the database for information (such as ```show tables``` and ```explain select```). Weighing the pros and cons as well as past experience, it is preferable to run this script on the same machine as the database server. 

If this will be an issue in the future, I will make changes to the script.

Another important step that this script takes is try to reduce the IO is to compress the slow log and then uncompress it to read into ```pt-query-digest```. This greatly reduces repeat usage of IO and as ```pt-query-digest``` cannot process the data that quickly, the decompression and CPU usage is throttled greatly.

### But I use RDS. How would I use this?

There is [a way to get a slow log](http://www.iheavy.com/2014/06/02/howto-automate-mysql-slow-query-analysis-with-amazon-rds/) from AWS for ```pt-query-digest``` to process them.
