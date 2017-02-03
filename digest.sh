#!/bin/sh
echo "Getting background information..."
./pt-summary >summary.txt 2>/dev/null
./pt-mysql-summary >mysql_summary.txt 2>/dev/null
cp /etc/my.cnf . 2>/dev/null
cp /etc/mysql/my.cnf . 2>/dev/null
df -h > df.txt

echo "Retrieving Slow log file.."
cat $1 | gzip - > slow.log.gz

echo "Processing Slow log file.."
zcat slow.log.gz | ./pt-query-digest --limit=8 > slow.txt
zcat slow.log.gz | ./pt-query-digest --filter '($event->{Rows_examined} > 1000)' --limit=8>bulky.txt
zcat slow.log.gz | ./pt-query-digest --limit=5 --group-by tables >tables.txt 2>/dev/null
zcat slow.log.gz | ./pt-query-digest --limit=8 --order-by=Lock_time:max > locked.txt 2>/dev/null
zcat slow.log.gz | ./pt-query-digest --limit=5 --group-by tables --order-by=Lock_time:sum > locked_tables.txt 2>/dev/null
zcat slow.log.gz | ./pt-query-digest  --filter '($event->{arg} =~ m/^(!?select)/)' --limit=8 --order-by=Query_time:max > select.txt
zcat slow.log.gz | ./pt-query-digest  --filter '($event->{Rows_examined} > 0) && ($event->{Row_ratio} = $event->{Rows_sent} / ($event->{Rows_examined})) && 1' --limit=8 > select_ratio.txt
cat slow.txt tables.txt select.txt bulky.txt locked_tables.txt | grep '#' | grep 'SHOW' | sed 's/#    //g' | sort | uniq | mysql -f > showtables.txt 2>/dev/null
cat slow.txt tables.txt locked_tables.txt | grep '#' | grep 'SHOW' | sed 's/#    //g' | sort | uniq | grep 'SHOW CREATE TABLE' | sed 's/SHOW CREATE TABLE //g' | sed 's/`//g' | sed 's/\\G//g' | grep -E '(\.){1}' > table_list.txt

echo "Retreiving data on possible bottleneck tables.."
while read -r line
do
        database="${line%.*}"
        table="${line#*.}"
        event='$event'
        zcat slow.log.gz | ./pt-query-digest --filter '(($event->{db} || "") =~ m/$database/) && ((($event->{arg}) =~ m/$table /) || (($event->{arg}) =~ m/\`$table\`/))' --limit=100% --explain 127.0.0.1 --sample 99 > $line.txt
done < "table_list.txt"

rm -f *.gz
echo "Reports generated."
