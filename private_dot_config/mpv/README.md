### Sponsorblock

Download from:
https://codeberg.org/jouni/mpv_sponsorblock_minimal

In order to work with local files downloaded with dlp, add the following
pattern to the urls list in fetch_ranges():

    function fetch_ranges()
        local urls = {
    ...
            "[%d]+%-[%d]+%-[%d]+%-[%d]+%-[%d]+%-[%d]+ %- ([%w-_]+) %- ",
        }

This matches for the youtube_id in local files end enables the sponsorblock
functionality.


### UI

Download from:
https://github.com/tomasklaen/uosc
and
https://github.com/po5/thumbfast
