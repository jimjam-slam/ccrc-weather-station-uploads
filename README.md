# ccrc-weather-station-uploads
A collection of scripts run to upload images and video from the CCRC weather station.

## Things you'll need
This is missing a couple of external scripts, which should be placed in the same directory and configured by filling in API tokens, secrets, etc.:
- `https://github.com/ohookins/flickr-shell-uploader`
- `https://code.google.com/p/youtube-api-samples/source/browse/samples/python/upload_video.py`
The following scripts use a python2 virtual environment that I've installed at `venv/bin/python`. They also use some music in this directory. I'm using `waltz-flowers-tchaikovsky.mp3` (shut up). Finally, you'll need a fairly new version of ffmpeg for this, as earlier versions don't seem to support passing file metadata using the concat filter. I've tested a static build of 2.8.4. If you'd prefer to change the music or use another copy of python or ffmpeg installed elsewhere, you can change those references in these scripts:
- `custom-youtube.sh`
- `sunrise-youtube.sh`
- `sunset-youtube.sh`
- `overnight-youtube.sh`
The reason I've hardcoded these paths in is that these scripts are scheduled by `get-sun-times.sh`, so they don't have access to $PATH. If you have a better way for me to handle this, please submit a pull request!

Finally, add `get-sun-times.sh` to your crontab using `crontab -e`. Add the following line (I schedule it at 0400, since the overnight script runs at 0410).

