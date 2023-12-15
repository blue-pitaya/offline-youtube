# Youtube subs fetcher

Simple perl script to download new videos from certain channels.

## Usage

0. Make sure you have `yt-dlp` installed. On arch linux: `sudo pacman -S yt-dlp`.
1. Create file `$HOME/Videos/subs.conf`.
2. Add urls for videos you want to subscribe. For example: `https://www.youtube.com/@Wendigoon`. All lines that nor start with `http` will be ignored.
3. Run script. On first run it only will fetch all video ids from channels. On next runs it will check if there are new videos on channel and download them.

## Notes

I made this script mainly for personal useage, so there are practicly no personalization options, unless you change the script itself.
