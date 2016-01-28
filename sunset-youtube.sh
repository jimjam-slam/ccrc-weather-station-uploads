#!/bin/bash -l
# render an image sequence of this morning's sunset and upload to youtube
# designed to be scheduled by get-sun-times.sh
# james goldie, climate change research centre, unsw australia, 2015-2016
# argument: path to the scripts folder (paths are relative!)

# import $SUNSET_START and $SUNSET_END
DATA_DIR="$1"
TODAY=$(date +"%Y-%m-%d")
SUNSET_START=`cat sunset-start.txt`
SUNSET_END=`cat sunset-end.txt`

# convert sunrise start and end times to 'n minutes ago' format for find
SUNSET_START=$(date --date="$SUNSET_START" +%s)
SUNSET_END=$(date --date="$SUNSET_END" +%s)
NOW=$(date +%s)
SUNSET_START=$((($NOW - $SUNSET_START) / 60))
SUNSET_END=$((($NOW - $SUNSET_END) / 60))

# get the list of files in the matching date-time range
find "$DATA_DIR"/images -type f -mmin -"$SUNSET_START" -mmin +"$SUNSET_END" > sunset-list.txt

# transform file list to prep for ffmpeg (including adding metadata) line-by-line
EXT=".jpg"
while read FULLNAME; do
    # extract date-time part of filename
    if [[ $FULLNAME =~ [0-9]{4}.[0-9]{2}.[0-9]{2}.[0-9]{4}.[0-9]{2} ]]; then
        DT="${BASH_REMATCH[0]}"
    fi

    printf "file \'$FULLNAME\'\nfile_packet_metadata dt=$DT\n" >> sunset-list2.txt
done <sunset-list.txt
mv sunset-list2.txt sunset-list.txt

# render the video
nice -n 20 ffmpeg/ffmpeg -threads 6 -f concat -r 30 \
    -i sunset-list.txt -i \
    waltz-flowers-tchaikovsky.mp3 \
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
    -shortest "$DATA_DIR"/videos/sunset-"$TODAY".mov

# upload the video
# nb: if the auth token expires, upload_video.py will require user intervention, which will stuff running this scheduled
venv/bin/python upload_video.py \
    --file "$DATA_DIR"/videos/sunset-"$TODAY".mov \
    --title="Sydney sunset $(date +"%d %b %Y")" \
    --description="Timelapse of Sydney shot at sunset from a weather station on top of the Mathews building at the University of New South Wales, Kensington. Taken by the Climate Change Research Centre (ccrc.unsw.edu.au)" \
    --keywords="ccrc weather,weather station,aws,unsw,kensington,sydney,australia,automatic,outdoor,sky,sunset,timelapse,weather,$(date +"%b"),$(date +"%Y")" \
    --noauth_local_webserver

rm -f "$DATA_DIR"/videos/sunset-"$TODAY".mov
# rm -f sunset-list.txt
# rm -f sunset-list2.txt
rm -f sunset-start.txt
rm -f sunset-end.txt

