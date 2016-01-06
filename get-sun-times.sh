#!/bin/bash -l

cd ${0%/*}
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
echo "overnight-youtube.sh > overnight-log.txt 2>&1" | at "now + 10 minutes"
echo "sunrise-youtube.sh > sunrise-log.txt 2>&1" | at $(date --date="$SUNRISE + 55 minutes" +"%H:%M")
echo "sunset-youtube.sh > sunset-log.txt 2>&1" | at $(date --date="$SUNSET + 55 minutes" +"%H:%M")

