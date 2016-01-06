#!/bin/bash

cd /home/z3479352/ccrcpi-scripts
DATA_DIR="/srv/ccrc/data48/z3479352/ccrc-weather"

# if latest image is more than 5 mins old, abort:
# camera has probably stopped for some reason
PIC_AGE=$(find "$DATA_DIR"/images/latest.jpg -mmin +4 | wc -l)
if [ $PIC_AGE -gt 0 ]
then
	exit 1
fi

# will run as a cron job every 5 mins (:03, :08, :13, ...)
DATETIME=$(date +"%Y %b %d %H:%M")
HOUR=$(date +"%H")

case $HOUR in
	00) TIME_OF_DAY="night";;
	01) TIME_OF_DAY="night";;
	02) TIME_OF_DAY="night";;
	03) TIME_OF_DAY="night";;
	04) TIME_OF_DAY="night";;
	05) TIME_OF_DAY="early morning";;
	06) TIME_OF_DAY="early morning";;
	07) TIME_OF_DAY="early morning";;
	08) TIME_OF_DAY="early morning";;
	09) TIME_OF_DAY="morning";;
	10) TIME_OF_DAY="morning";;
	11) TIME_OF_DAY="morning";;
	12) TIME_OF_DAY="afternoon";;
	13) TIME_OF_DAY="afternoon";;
	14) TIME_OF_DAY="afternoon";;
	15) TIME_OF_DAY="afternoon";;
	16) TIME_OF_DAY="evening";;
	17) TIME_OF_DAY="evening";;
	18) TIME_OF_DAY="evening";;
	19) TIME_OF_DAY="evening";;
	20) TIME_OF_DAY="evening";;
	21) TIME_OF_DAY="night";;
	22) TIME_OF_DAY="night";;
	23) TIME_OF_DAY="night";;
esac

TITLE="Sydney $DATETIME"
DESCRIPTION="View of Sydney shot from a weather station on top of the Mathews building at the University of New South Wales, Kensington. Shot taken by the Climate Change Research Centre (http://ccrc.unsw.edu.au) at $DATETIME."
TAGS="ccrc,weather,weather station,aws,unsw,kensington,sydney,australia,automatic,outdoor,sky,$(date +"%Y"),$(date +"%b"),$TIME_OF_DAY"
echo `cp "$DATA_DIR"/images/latest.jpg "$DATA_DIR"/images/flickr.jpg`
#flickr-shell-uploader [-t TITLE] [-d DESCRIPTION] [-a TAGS] [-p IS_PUBLIC] [-f IS_FRIEND] [-m IS_FAMILY] [-s SAFETY_LEVEL] [-c CONTENT_TYPE] [-h HIDDEN] -i <file> [-i <file> ...]
bash flickr-shell-uploader -t "$TITLE" -d "$DESCRIPTION" -a "$TAGS" -p 1 -f 1 -m 1 -s 1 -c 1 -h 1 -i "$DATA_DIR"/images/flickr.jpg
echo "Flickr upload script complete"

