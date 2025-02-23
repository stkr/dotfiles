#!/usr/bin/env python

import argparse
import datetime
import json
import pathlib
import pprint
import string
import subprocess
import re
import logging

YT_DLP_PATH='/home/stefan/.local/bin/yt-dlp'
MPV_PATH='/usr/bin/mpv'

VIDEO_DIR_PATH = '/home/stefan/.tmp/videos'
LOG_FILE_PATH = VIDEO_DIR_PATH + '/download_and_play.log'

logger = logging.getLogger(__name__)
logging.basicConfig(filename=LOG_FILE_PATH,
                    level=logging.INFO)

def get_video_path(video_dir, filename):
    return [f for f in video_dir.glob(filename + "*") if not f.name.endswith("info.json")][0]

def sane_filename(filename):
    return re.sub(r'[^\s\w\d-]','_',filename)

def download(url):
    now = datetime.datetime.now()
    filename = str(now.strftime("%Y-%m-%d-%H-%M-%S-%f"))
    subprocess.run([YT_DLP_PATH, '-P', VIDEO_DIR_PATH, '-o', filename, '--write-info-json', url], check=True)

    video_dir = pathlib.Path(VIDEO_DIR_PATH)
    info_path = video_dir.joinpath(filename + ".info.json")
    video_path = get_video_path(video_dir, filename)
    with open(info_path, "r") as fp:
        video_info = json.load(fp)
    new_filename = (now.strftime("%Y-%m-%d-%H-%M-%S") + 
        " - " + sane_filename(video_info['id']) +
        " - " + sane_filename(video_info['title']) +
        video_path.suffix)
    new_path = video_dir.joinpath(new_filename)
    info_path.unlink()
    video_path.rename(new_path)
    return new_path

def play(video_path):
    subprocess.run([MPV_PATH, video_path])

def main():
    try:

        parser = argparse.ArgumentParser()
        parser.add_argument("url")
        args = parser.parse_args()
        video_path = download(args.url)
        play(video_path)
    except Exception as ex:
        logger.fatal(ex)
        raise(ex)

if __name__ == "__main__":
    main()
