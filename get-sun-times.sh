#!/bin/bash -l
# schedule weather station video rendering/upload jobs for the day
# james goldie, climate change research centre, unsw australia, 2015-2016

# arguments:
#   1) path to the scripts folder (paths are relative!)
#   2) path to the data directory
# add to crontab to schedule daily! eg:
# 0 4 * * * /mypath/ccrcpi-scripts/get-sun-times.sh /mypath/ccrcpi-scripts /otherpath/weathercam > /mypath/ccrcpi-scripts/get-sun-times-log.txt 2>&1

cd "$1"
DATA_DIR="$2"
# get sunrise and sunset times from the Yahoo! Weather API, then calculate the
# times at which to start and stop sunrise/sunset videos
l=1105779
SUNRISE=$(curl -s http://weather.yahooapis.com/forecastrss?w=$l|grep astronomy| awk -F\" '{print $2;}')
echo $(date --date="$SUNRISE - 45 minutes" +"%Y-%m-%d %H:%M:%S") > sunrise-start.txt
echo $(date --date="$SUNRISE + 50 minutes" +"%Y-%m-%d %H:%M:%S") > sunrise-end.txt
SUNSET=$(curl -s http://weather.yahooapis.com/forecastrss?w=$l|grep astronomy| awk -F\" '{print $4;}')
echo $(date --date="$SUNSET - 45 minutes" +"%Y-%m-%d %H:%M:%S") > sunset-start.txt
echo $(date --date="$SUNSET + 50 minutes" +"%Y-%m-%d %H:%M:%S") > sunset-end.txt

# schedule sunrise-youtube.sh and sunset-youtube.sh to run
# 50 mins after sunrise and sunset
echo "./overnight-youtube.sh $DATA_DIR > overnight-log.txt 2>&1" | at "now + 10 minutes"
echo "./sunrise-youtube.sh $DATA_DIR > sunrise-log.txt 2>&1" | at $(date --date="$SUNRISE + 55 minutes" +"%H:%M")
echo "./sunset-youtube.sh $DATA_DIR > sunset-log.txt 2>&1" | at $(date --date="$SUNSET + 55 minutes" +"%H:%M")

