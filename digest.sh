#!/bin/sh
path_to_executable=$(which pt-query-digest 2>/dev/null)
 if [ -x "$path_to_executable" ] ; then
    qdigest=$path_to_executable
 elif [ -f pt-query-digest ] ; then
    qdigest='./pt-query-digest'
 else
    wget percona.com/get/pt-query-digest
    chmod a+x pt-query-digest
    qdigest='./pt-query-digest'
 fi

echo "Retrieving Slow log file.."
if [ ! -f slow.log.gz ]; then
   cat $1 | gzip - > slow.log.gz
fi

echo "Processing Slow log file.."
zcat slow.log.gz | $qdigest --limit=8 > slow.txt &
zcat slow.log.gz | $qdigest --limit=8 --order-by=Lock_time:sum > locked.txt 2>/dev/null &
zcat slow.log.gz | $qdigest  --filter '($event->{Rows_examined} > 0) && ($event->{Row_ratio} = $event->{Rows_sent} / ($event->{Rows_examined})) && 1' --limit=8 > select_ratio.txt &
wait

echo '' > result.txt
cat slow.txt | sed -nr '/# Profile/,/# MISC/p' | sed 's/# Profile/# Top Slow Queries:/g' >> result.txt
echo '' >> result.txt
cat locked.txt | sed -nr '/# Profile/,/# MISC/p' | sed 's/# Profile/# Top Locked Queries:/g' >> result.txt
echo '' >> result.txt
cat select_ratio.txt | sed -nr '/# Profile/,/# MISC/p' | sed 's/# Profile/# Top Queries with high Select\/Sent Ratio:/g' >> result.txt
cat slow.txt | sed -nr '/# MISC/,//p' >> result.txt
cat locked.txt | sed -nr '/# MISC/,//p' >> result.txt
cat select_ratio.txt | sed -nr '/# MISC/,//p' >> result.txt

cat slow.txt select_ratio.txt locked.txt | grep '#' | grep 'SHOW' | sed 's/#    //g' | sort | uniq -c | sort -nr | grep 'SHOW CREATE TABLE' | head -n 5 | sed 's/SHOW CREATE TABLE //g' | sed 's/`//g' | sed 's/\\G//g' | grep -E '(\.){1}' | awk '{print $2}' > table_list.txt

rm slow.txt 
rm locked.txt 
rm select_ratio.txt

echo "Retreiving data on possible bottleneck tables.."
while read -r line
do
        database="${line%.*}"
        table="${line#*.}"
        event='$event'
        zcat slow.log.gz | $qdigest --filter "(($event->{db} || '') =~ m/$database/) && ((($event->{arg}) =~ m/$table /) || (($event->{arg}) =~ m/\`$table\`/))" --limit=100% > $line.txt &
done < "table_list.txt"
wait

rm table_list.txt

echo "Reports generated."

if [ ! -f reports.tar.gz ]; then
  tar czvf reports.tar.gz *.txt 2>/dev/null
fi

