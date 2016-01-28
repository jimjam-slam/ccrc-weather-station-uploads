#!/bin/bash -l
# render an image sequence of the previous night and upload to youtube
# designed to be scheduled by get-sun-times.sh
# james goldie, climate change research centre, unsw australia, 2015-2016

# import $OVERNIGHT_START and $OVERNIGHT_END
DATA_DIR="$1"
TODAY=$(date +"%Y-%m-%d")

# convert overnight start and end times to 'n minutes ago' format for find
OVERNIGHT_START=$(date --date="yesterday 21:00" +%s)
OVERNIGHT_END=$(date --date="today 04:00" +%s)
NOW=$(date +%s)
OVERNIGHT_START=$((($NOW - $OVERNIGHT_START) / 60))
OVERNIGHT_END=$((($NOW - $OVERNIGHT_END) / 60))

# get the list of files in the matching date-time range
find "$DATA_DIR"/images -type f -mmin -"$OVERNIGHT_START" -mmin +"$OVERNIGHT_END" > overnight-list.txt

# transform file list to prep for ffmpeg (including adding metadata) line-by-line
EXT=".jpg"
while read FULLNAME; do
    # extract date-time part of filename
    if [[ $FULLNAME =~ [0-9]{4}.[0-9]{2}.[0-9]{2}.[0-9]{4}.[0-9]{2} ]]; then
        DT="${BASH_REMATCH[0]}"
    fi

    printf "file \'$FULLNAME\'\nfile_packet_metadata dt=$DT\n" >> overnight-list2.txt
done <overnight-list.txt
mv overnight-list2.txt overnight-list.txt

# render the video
nice -n 20 ffmpeg/ffmpeg -threads 6 -f concat -r 30 \
    -i overnight-list.txt \
    -i waltz-flowers-tchaikovsky.mp3 \
    -threads 6 \
    -vf "crop=2592:1458:0:450, \
        drawtext=fontfile=RobotoCondensed-Italic.ttf:\
            fontsize=48:\
            fontcolor=0xFFFFFF:\
            shadowcolor=0x00000088:\
            shadowx=5:\
            shadowy=5:\
            text='%{metadata\\:dt}':\
            x=20:\
            y=h-32-106-th, \
        drawtext=fontfile=RobotoCondensed-Regular.ttf:\
            fontsize=48:\
            fontcolor=0xFFFFFF:\
            shadowcolor=0x00000088:\
            shadowx=5:\
            shadowy=5:\
            text='Climate Change Research Centre':\
            x=20:\
            y=h-32-48-th, \
        drawtext=fontfile=RobotoCondensed-Regular.ttf:\
            fontsize=48:\
            fontcolor=0xFFFFFF:\
            shadowcolor=0x00000088:\
            shadowx=5:\
            shadowy=5:\
            text='Sydney, Australia':\
            x=20:\
            y=h-32-th" \
    -shortest "$DATA_DIR"/videos/overnight-"$TODAY".mov

# upload the video
# nb: if the auth token expires, upload_video.py will require user intervention, which will stuff running this scheduled
venv/bin/python upload_video.py \
    --file "$DATA_DIR"/videos/overnight-"$TODAY".mov \
    --title="Sydney overnight $(date +"%d %b %Y")" \
    --description="Timelapse of Sydney from 9 PM to 4 AM shot from a weather station on top of the Mathews building at the University of New South Wales, Kensington. Taken by the Climate Change Research Centre (ccrc.unsw.edu.au)" \
    --keywords="ccrc weather,weather station,aws,unsw,kensington,sydney,australia,automatic,outdoor,sky,overnight,timelapse,weather,$(date +"%b"),$(date +"%Y")" \
    --noauth_local_webserver

rm -f "$DATA_DIR"/videos/overnight-"$TODAY".mov
# rm -f overnight-list2.txt
# rm -f overnight-list.txt

