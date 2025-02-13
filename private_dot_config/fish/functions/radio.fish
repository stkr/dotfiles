
set -g _radio_station_shortcuts "AS"
set -g _radio_station_names "Antenne Steiermark"
set -g _radio_station_urls "http://live.antenne.at/as"


function _radio_save
    if test (count $argv) -lt 1
        echo "Not enough arguments. Usage: save STATION."
        return 1
    end

    set -l idx (contains -i $_radio_station_shortcuts $argv)

    set -l url $_radio_station_urls[$idx]
    set -l name $_radio_station_names[$idx]

    set -l now (date +%Y-%m-%dT%H-%M)

    if test (count $argv) -lt 2
        # No duration argument, we just start the download, 
        # user needs to terminate himself.
        yt-dlp -o "$now - $name.mp3" "$url"
    else
        # Duration is given in seconds
        yt-dlp -o "$now - $name.mp3" "$url" --downloader ffmpeg \
            --downloader-args ffmpeg:"-t $argv[2]"
    end
end

function _radio_play
    if test (count $argv) -lt 1
        echo "Not enough arguments. Usage: play STATION."
        return 1
    end

    set -l idx (contains -i $_radio_station_shortcuts $argv)
    set -l url $_radio_station_urls[$idx]
    mpv "$url"
end



function radio -d "Helper for dealing with online radio streams"
    # We tell argparse about -h/--help and others -these are short and long
    # forms of the same option. The "--" here is mandatory, it tells it from
    # where to read the arguments.
    argparse h/help -- $argv; or return

    # If -h or --help is given, we print a little help text and return
    if set -ql _flag_help || test (count $argv) -lt 1
        echo "Usage:                                                     "
        echo "    radio command                                          "
        echo "                                                           "
        echo "Valid commands:                                            "
        echo "    * save: Save the stream to the current working         "
        echo "      directory.                                           "
        echo "    * play: Play the stream in mpv.                        "

        return 0
    end
    switch $argv[1]
        case save
            _radio_save $argv[2..-1]
        case play
            _radio_play $argv[2..-1]
        case '*'
            echo Unsupported command \"$argv[1]\"
            return 1
    end
end
