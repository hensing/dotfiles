#!/bin/sh
#
# Skript zum Auslesen der Mainboard-Temperatur
# by H.Dickten 09.02.2012

# settings:
SENSOR="MB Temp"
LOGHOST="localhost"
LOGFILE="$HOME/temperatures.log"

# get data:
TEMP=`/usr/bin/sensors |grep "$SENSOR" |cut -d'+' -f2 | cut -d'.' -f 1`
CTIME=`date +%s`
HOSTNAME=`hostname`
LOGENTRY="$CTIME $HOSTNAME: $TEMP"

# write log to file:
ssh $LOGHOST "echo $LOGENTRY >> $LOGFILE"
