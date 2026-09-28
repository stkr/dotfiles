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
    echo "  merge <video> <audio1> [audio2 ...]    Merge a video with one or more audio tracks"
    echo ""
    echo "Examples:"
    echo "  videdit split video.mp4"
    echo "  videdit merge video.mp4 german.m4a english.m4a"
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
    if test (count $argv) -lt 2
        echo "Error: Missing arguments" >&2
        echo "Usage: videdit merge <video> <audio1> [audio2 ...]" >&2
        return 1
    end

    set -l video_file $argv[1]
    set -l audio_files $argv[2..-1]

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

    set -l base_name (string replace -r '\.[^.]*$' '' "$video_file")
    set -l output "$base_name"_merged.mkv

    # Build the ffmpeg argument list:
    #   -i <video> -i <audio1> -i <audio2> ...
    #   -map 0:v -map 1:a -map 2:a ...
    #   -metadata:s:a:0 title="<title1>"
    #   -metadata:s:a:1 title="<title2>" ...
    #   -c:v copy -c:a copy -shortest <output>
    set -l ffmpeg_args
    set -a ffmpeg_args -i "$video_file"
    for f in $audio_files
        set -a ffmpeg_args -i "$f"
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
    for f in $audio_files
        echo "  + $f"
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

# `merge` takes a video file first, then one or more audio files.
# Helper: has the video argument already been supplied on the current line?
function __videdit_merge_has_video --description "True if 'merge' already received its video arg"
    set -l tokens (commandline -opc)
    # tokens: videdit merge [args...]  → length >= 3 means an arg followed "merge"
    test (count $tokens) -ge 3
end

for ext in mp4 mkv mov avi webm m4v
    complete -c videdit -n "__fish_seen_subcommand_from merge; and not __videdit_merge_has_video" \
        -a "(__fish_complete_suffix .$ext)"
end
for ext in m4a mp3 aac opus flac wav ogg
    complete -c videdit -n "__fish_seen_subcommand_from merge; and __videdit_merge_has_video" \
        -a "(__fish_complete_suffix .$ext)"
end
