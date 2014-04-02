#!/bin/bash
#
# Condor Status für i3bar - by H.Dickten 2012

GREP_NICE=`condor_status -submitters |grep -m1 "^nice-user.$USER@"`
GREP_NORM=`condor_status -submitters |grep -m1 "^$USER@"`

if [ -n "$GREP_NICE" ]
then
    STAT=`awk '{ print "R: "$3, "I: "$4, "H: "$5 " @nice" }' <<< $GREP_NICE`
elif [ -n "$GREP_NORM" ]
then
    STAT=`awk '{ print "R: "$3, "I: "$4, "H: "$5 }' <<< $GREP_NORM`
else
STAT="condor idle"
fi

echo $STAT


