#!/bin/bash

# Download oldest first
#--playlist-reverse

# Name the files by their title, in data directory
#--o "./data/%(title)s.%(ext)s"

# Maintain a list of downloaded files, don't re-download
#--download-archive downloaded.txt 

# Don't overwrite files
#--no-overwrites

# Convert to audio only
#--extract-audio 

# As mp3
#--audio-format mp3 

# Best audio quality
#--audio-quality 0

# Prefer ffmpeg over avconv for running the postprocessors (default)
#--prefer-ffmpeg

# Write video description to a .description file
#--write-description 

# Write video metadata to a .info.json file
#--write-info-json

# Write thumbnail image to disk
#--write-thumbnail

# Download only videos uploaded on or after this date (i.e. inclusive) YYYYMMDD
#--dateafter  20190304

# Read list of channels from file
#-a channels.txt

ytdl=`readlink -f $(dirname $0)`/youtube-dl

if [ ! -x "$ytdl" ]; then
    curl -L https://yt-dl.org/downloads/latest/youtube-dl -o "$ytdl"
    chmod a+rx "$ytdl"
fi

chnls=`readlink -f $(dirname $0)`/channels.txt
downlds=`readlink -f $(dirname $0)`/downloaded.txt

logDate=$(date +%Y%m%d)
feedDate=$(date +%Y%m%d -d "-1 month")
eval `cat config.ini`

mkdir -p $path/data

# Update youtube-dl
$ytdl -U

# Download and convert files
$ytdl --ignore-errors --playlist-reverse --output "$path/data/%(id)s.%(ext)s" --download-archive "$downlds" --no-overwrites --extract-audio --audio-format mp3 --audio-quality 0 --prefer-ffmpeg --write-description --write-info-json --write-thumbnail --dateafter $feedDate -a "$chnls" -v | tee -a "$path/data/log-$logDate.log"

# Also put all downloaded webpages that were out of data range into the downloaded.txt to avoid redownloads
for webpage in `grep -oP "(?<=\\[youtube\\] ).*(?=: Downloading webpage)" "$path/data/log-$logDate.log"`; do
    echo "youtube $webpage" >> "$downlds"
done
alldownloaded=`cat "$downlds" | sort | uniq`
echo "$alldownloaded" > "$downlds"

# Remove files older than 60 days
find $path/data/ -mtime +60 -type f -delete >> "$path/data/log-$logDate.log"

python3 index.py "$path" "$baseUrl"
