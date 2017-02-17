#!/bin/bash
path_to_executable=$(which pt-summary 2>/dev/null)
 if [ -x "$path_to_executable" ] ; then
    qsummary=$path_to_executable
 elif [ -f pt-summary ] ; then
    qsummary='./pt-summary'
 else
    wget percona.com/get/pt-summary
    chmod a+x pt-summary
    qsummary='./pt-summary'
 fi

path_to_executable=$(which pt-mysql-summary 2>/dev/null)
 if [ -x "$path_to_executable" ] ; then
    qmysql=$path_to_executable
 elif [ -f pt-mysql-summary ] ; then
    qmysql='./pt-mysql-summary'
 else
    wget percona.com/get/pt-mysql-summary
    chmod a+x pt-mysql-summary
    qmysql='./pt-mysql-summary'
 fi

echo "Getting background information..."
$qsummary >summary.txt 2>/dev/null
$qmysql >>summary.txt 2>/dev/null
df -h >> summary.txt
