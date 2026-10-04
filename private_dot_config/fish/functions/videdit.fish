# videdit - simple command-line video editing utility
#
# Install:
#   Save this file to ~/.config/fish/functions/videdit.fish
#   Then run once:  source ~/.config/fish/functions/videdit.fish
#   (or just open a new shell and call `videdit` once to autoload it)
#
# To add a new command:
#   1. Add a `case <name>` branch in the switch below.
#   2. Add the name to $videdit_commands (used for completion).
#   3. Add a `complete -c videdit ...` line at the bottom.

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
# Language codes recognised inside audio filenames when deriving track titles
# for `merge`. Add new codes here to extend the lookup; the first match wins.
# Matching is case-insensitive and substring-based, so "german.m4a" → "ger"
# and "audio_ENG.m4a" → "eng".
set -g videdit_lang_codes ger eng fra spa ita jpn chi rus por

# ---------------------------------------------------------------------------
# Main dispatcher
# ---------------------------------------------------------------------------
function videdit --description "Simple command-line video editing utility"
    if test (count $argv) -eq 0
        __videdit_usage
        return 1
    end

    set -l command $argv[1]
    set -l args $argv[2..-1]

    switch $command
        case split
            __videdit_split $args
        case merge
            __videdit_merge $args
        case help --help -h
            __videdit_usage
        case '*'
            echo "Error: Unknown command '$command'" >&2
            echo "Run 'videdit help' for usage information" >&2
            return 1
    end
end

function __videdit_usage --description "Print videdit usage"
    echo "Usage: videdit <command> [options]"
    echo ""
    echo "Commands:"
    echo "  split <filename>                       Split video into separate audio and video files"
    echo "  merge [options] <video> <audio1> [audio2 ...]"
    echo "                                         Merge a video with one or more audio tracks"
    echo ""
    echo "Merge options:"
    echo "  -d, --delay <seconds>                  Delay the corresponding audio stream."
    echo "                                         May be repeated: the Nth --delay applies"
    echo "                                         to the Nth audio file. Unspecified streams"
    echo "                                         default to 0. Negative values are allowed."
    echo ""
    echo "Examples:"
    echo "  videdit split video.mp4"
    echo "  videdit merge video.mp4 german.m4a english.m4a"
    echo "  videdit merge -d 0.5 -d -0.25 video.mp4 ger.m4a eng.m4a"
end

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
# Derive a track title from an audio filename. Returns a recognised language
# code if one appears in the name, otherwise the filename's basename.
function __videdit_lang_title --description "Derive an audio track title from a filename"
    set -l name (basename $argv[1])
    set -l base (string replace -r '\.[^.]*$' '' "$name")

    for code in $videdit_lang_codes
        if string match -qi "*$code*" -- $base
            echo $code
            return 0
        end
    end

    echo $base
end

# Parse merge-subcommand arguments. Emits one tagged line per item:
#   D <value>   for each --delay/-d value, in order of appearance
#   P <value>   for each positional argument, in order of appearance
#   E <msg>     for the first error encountered (nothing else is emitted
#               after this line)
# Callers consume the output with a `for line in (...)` loop. Values with
# embedded spaces are fine; only literal newlines in an argument would break
# the protocol, which is irrelevant for real-world video/audio paths.
function __videdit_merge_parse --description "Parse merge subcommand arguments"
    set -l end_of_opts 0
    set -l i 1
    while test $i -le (count $argv)
        set -l arg $argv[$i]
        if test $end_of_opts -eq 1
            echo "P $arg"
        else
            switch $arg
                case -d --delay
                    set i (math $i + 1)
                    if test $i -gt (count $argv)
                        echo "E '$arg' requires a value"
                        return 1
                    end
                    echo "D $argv[$i]"
                case '--delay=*'
                    echo "D "(string replace '--delay=' '' -- $arg)
                case '-d?*'
                    echo "D "(string replace -r '^-d' '' -- $arg)
                case '--'
                    set end_of_opts 1
                case '-*'
                    echo "E unknown option '$arg'"
                    return 1
                case '*'
                    echo "P $arg"
            end
        end
        set i (math $i + 1)
    end
end

# ---------------------------------------------------------------------------
# Subcommand: split
# ---------------------------------------------------------------------------
function __videdit_split --description "Split video into separate audio and video files"
    if test (count $argv) -eq 0
        echo "Error: Missing filename" >&2
        echo "Usage: videdit split <filename>" >&2
        return 1
    end

    set -l input_file $argv[1]

    if not test -f "$input_file"
        echo "Error: File '$input_file' not found" >&2
        return 1
    end

    if not command -q ffmpeg
        echo "Error: ffmpeg is not installed or not in PATH" >&2
        return 1
    end

    set -l base_name (string replace -r '\.[^.]*$' '' "$input_file")
    set -l video_output "$base_name"_video.mp4
    set -l audio_output "$base_name"_audio.m4a

    echo "Splitting '$input_file'..."
    echo "  Video output: $video_output"
    echo "  Audio output: $audio_output"

    ffmpeg -i "$input_file" \
        -map 0:v:0 -c copy -an "$video_output" \
        -map 0:a:0 -c copy -vn "$audio_output"

    if test $status -eq 0
        echo "✓ Successfully split '$input_file'"
    else
        echo "✗ Error: ffmpeg failed to split the file" >&2
        return 1
    end
end

# ---------------------------------------------------------------------------
# Subcommand: merge
# ---------------------------------------------------------------------------
function __videdit_merge --description "Merge a video with one or more audio tracks"
    # Consume the tagged output of __videdit_merge_parse.
    set -l delays
    set -l positional
    for line in (__videdit_merge_parse $argv)
        set -l tag (string sub -l 1 -- $line)
        set -l val (string sub -s 3 -- $line)
        switch $tag
            case D
                set -a delays $val
            case P
                set -a positional $val
            case E
                echo "Error: $val" >&2
                echo "Usage: videdit merge [--delay <seconds>]... <video> <audio1> [audio2 ...]" >&2
                return 1
        end
    end

    if test (count $positional) -lt 2
        echo "Error: Missing arguments" >&2
        echo "Usage: videdit merge [--delay <seconds>]... <video> <audio1> [audio2 ...]" >&2
        return 1
    end

    set -l video_file $positional[1]
    set -l audio_files $positional[2..-1]

    if test (count $delays) -gt (count $audio_files)
        echo "Error: More --delay values than audio files" >&2
        return 1
    end

    if not test -f "$video_file"
        echo "Error: File '$video_file' not found" >&2
        return 1
    end

    for f in $audio_files
        if not test -f "$f"
            echo "Error: File '$f' not found" >&2
            return 1
        end
    end

    if not command -q ffmpeg
        echo "Error: ffmpeg is not installed or not in PATH" >&2
        return 1
    end

    # Resolve one delay per audio file (default 0).
    set -l per_stream_delays
    for idx in (seq (count $audio_files))
        if test $idx -le (count $delays)
            set -a per_stream_delays $delays[$idx]
        else
            set -a per_stream_delays 0
        end
    end

    set -l base_name (string replace -r '\.[^.]*$' '' "$video_file")
    set -l output "$base_name"_merged.mkv

    # Build the ffmpeg argument list:
    #   -i <video>
    #   -itsoffset <d1> -i <audio1>
    #   -itsoffset <d2> -i <audio2> ...
    #   -map 0:v -map 1:a -map 2:a ...
    #   -metadata:s:a:0 title="<title1>"
    #   -metadata:s:a:1 title="<title2>" ...
    #   -c:v copy -c:a copy -shortest <output>
    set -l ffmpeg_args
    set -a ffmpeg_args -i "$video_file"
    for idx in (seq (count $audio_files))
        set -l d $per_stream_delays[$idx]
        if test "$d" != "0"
            set -a ffmpeg_args -itsoffset "$d"
        end
        set -a ffmpeg_args -i "$audio_files[$idx]"
    end

    set -a ffmpeg_args -map 0:v
    for i in (seq (count $audio_files))
        set -a ffmpeg_args -map "$i:a"
    end

    for i in (seq (count $audio_files))
        set -l title (__videdit_lang_title $audio_files[$i])
        set -l idx (math $i - 1)
        set -a ffmpeg_args "-metadata:s:a:$idx" "title=$title"
    end

    set -a ffmpeg_args -c:v copy -c:a copy -shortest "$output"

    echo "Merging '$video_file' with audio track(s):"
    for idx in (seq (count $audio_files))
        set -l d $per_stream_delays[$idx]
        set -l suffix ""
        if test "$d" != "0"
            set suffix " (delay: $d s)"
        end
        echo "  + $audio_files[$idx]$suffix"
    end
    echo "  Output: $output"
    echo "  Track titles:"
    for i in (seq (count $audio_files))
        set -l title (__videdit_lang_title $audio_files[$i])
        set -l idx (math $i - 1)
        echo "    audio:$idx → $title"
    end

    ffmpeg $ffmpeg_args

    if test $status -eq 0
        echo "✓ Successfully merged into '$output'"
    else
        echo "✗ Error: ffmpeg failed to merge" >&2
        return 1
    end
end

# ---------------------------------------------------------------------------
# Tab completions
# ---------------------------------------------------------------------------
# Running this block at load time registers the completions. It's safe to
# re-source this file: `complete` replaces existing rules with the same
# conditions rather than accumulating duplicates.

set -l videdit_commands split merge help

# No default file completion at the top level — we only want subcommands.
complete -c videdit -f

# Offer subcommands until one has been entered.
complete -c videdit -n "not __fish_seen_subcommand_from $videdit_commands" \
    -a split -d "Split video into separate audio and video files"
complete -c videdit -n "not __fish_seen_subcommand_from $videdit_commands" \
    -a merge -d "Merge a video with one or more audio tracks"
complete -c videdit -n "not __fish_seen_subcommand_from $videdit_commands" \
    -a help  -d "Show usage information"

# `split` takes a video file — complete with common video extensions.
for ext in mp4 mkv mov avi webm m4v
    complete -c videdit -n "__fish_seen_subcommand_from split" \
        -a "(__fish_complete_suffix .$ext)"
end

# `merge` accepts a repeatable --delay option.
complete -c videdit -n "__fish_seen_subcommand_from merge" \
    -s d -l delay -d "Delay the corresponding audio stream (repeatable)" -r

# Helper: has the video argument already been supplied on the current line?
# Reuses __videdit_merge_parse so it stays in lockstep with the real parser —
# if the parsing rules ever change, both places update together.
function __videdit_merge_has_video --description "True if 'merge' already received its video arg"
    set -l tokens (commandline -opc)
    set -l merge_idx (contains -i -- merge $tokens)
    test -n "$merge_idx"; or return 1
    set -l args $tokens[(math $merge_idx + 1)..-1]
    __videdit_merge_parse $args | string match -q 'P *'
end

for ext in mp4 mkv mov avi webm m4v
    complete -c videdit -n "__fish_seen_subcommand_from merge; and not __videdit_merge_has_video" \
        -a "(__fish_complete_suffix .$ext)"
end
for ext in m4a mp3 aac opus flac wav ogg
    complete -c videdit -n "__fish_seen_subcommand_from merge; and __videdit_merge_has_video" \
        -a "(__fish_complete_suffix .$ext)"
end