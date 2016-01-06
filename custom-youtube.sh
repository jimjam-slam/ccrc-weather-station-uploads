#!/bin/bash -l

cd /home/z3479352/ccrcpi-scripts
DATA_DIR="/srv/ccrc/data48/z3479352/ccrc-weather"
VID_START="$1"
VID_END="$2"
TODAY=$(date +"%Y-%m-%d")
FRAME_RATE="$3"

# convert custom start and end times to 'n minutes ago' format for find
VID_START=$(date --date="$VID_START" +%s)
VID_END=$(date --date="$VID_END" +%s)
NOW=$(date +%s)
VID_START=$((($NOW - $VID_START) / 60))
VID_END=$((($NOW - $VID_END) / 60))

# get the list of files in the matching date-time range
find "$DATA_DIR"/images -type f -mmin -"$VID_START" -mmin +"$VID_END" > custom-list.txt

# transform file list to prep for ffmpeg (including adding metadata) line-by-line
IMG_PATH="$DATA_DIR"/images
EXT=".jpg"
while read FULLNAME; do
    # extract date-time part of filename
    if [[ $FULLNAME =~ [0-9]{4}.[0-9]{2}.[0-9]{2}.[0-9]{4}.[0-9]{2} ]]; then
        DT="${BASH_REMATCH[0]}"
    fi

    printf "file \'$FULLNAME\'\nfile_packet_metadata dt=$DT\n" >> custom-list2.txt
done <custom-list.txt
mv custom-list2.txt custom-list.txt

# render the video
nice -n 20 ffmpeg/ffmpeg -threads 6 -f concat -r "$FRAME_RATE" \
    -i custom-list.txt \
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
    -shortest "$DATA_DIR"/videos/custom-"$TODAY.mov"

# upload the video
# nb: if the auth token expires, upload_video.py will require user intervention, which will stuff running this scheduled
venv/bin/python upload_video.py \
    --file "$DATA_DIR"/videos/custom-"$TODAY".mov \
    --title="Sydney timelapse $(date +"%d %b %Y")" \
    --description="Timelapse of Sydney shot from a weather station on top of the Mathews building at the University of New South Wales, Kensington. Taken by the Climate Change Research Centre (ccrc.unsw.edu.au)" \
    --keywords="ccrc weather,weather station,aws,unsw,kensington,sydney,australia,automatic,outdoor,sky,highlights,timelapse,weather,$(date +"%b"),$(date +"%Y")" \
    --noauth_local_webserver

rm -f "$DATA_DIR"/videos/custom-"$TODAY".mov
#rm -f custom-list.txt
#rm -f custom-list2.txt

