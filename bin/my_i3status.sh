#!/bin/bash

COLOR=True

RUN=0
i3status | while :
do
    # i3status lesen:
    read line

    # condor stat abrufen:
    CONDOR=`condor_status -submitters |egrep "^(nice-user.)?$USER@" |head -n 2|paste -d " " - -`

    if [[ $CONDOR == *nice-user* ]]
    then
        STAT=`head -n 2 |paste -d " " - - |awk '{print "R: "$3"("$8") I: "$4"("$9") H: "$5"("$10")"}' <<< $CONDOR`
        #STAT=`awk '{ print "R: "$3, "I: "$4, "H: "$5 " @nice" }' <<< $GREP_NICE`
    elif [ -n "$CONDOR" ]
    then
        STAT=`awk '{ print "R: "$3, "I: "$4, "H: "$5 }' <<< $CONDOR`
    else
    STAT="condor idle"
    fi

    # Mit Farbe
    if [[ $COLOR = True ]]
    then
        if [[ $RUN -ge 3 ]]
        then
            echo ",[{\"name\":\"condor_stat\",\"full_text\":\"$STAT\"},${line:2}" || exit 1
        else
            echo $line
        fi
        let RUN=RUN+1

    # Ohne Farbe
    else
        echo "$STAT | $line" || exit 1
    fi
done
