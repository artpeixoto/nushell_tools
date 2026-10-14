def "nu-complete ffmpeg-help-topic" [] {
  [
    "long"
    "full"
    "decoder="
    "encoder="
    "demuxer="
    "muxer="
    "filter="
    "bsf="
    "protocol="
  ]
}

def "nu-complete ffmpeg-loglevel" [] {
  [
    "quiet"
    "panic"
    "fatal"
    "error"
    "warning"
    "info"
    "verbose"
    "debug"
    "trace"
  ]
}

def "nu-complete ffmpeg-target" [] {
  [
    "vcd"
    "svcd"
    "dvd"
    "dv"
    "dv50"
    "pal-vcd"
    "pal-svcd"
    "pal-dvd"
    "pal-dv"
    "pal-dv50"
    "ntsc-vcd"
    "ntsc-svcd"
    "ntsc-dvd"
    "ntsc-dv"
    "ntsc-dv50"
    "film-vcd"
    "film-svcd"
    "film-dvd"
    "film-dv"
    "film-dv50"
  ]
}

def "nu-complete ffmpeg-disposition" [] {
  [
    "default"
    "dub"
    "original"
    "comment"
    "lyrics"
    "karaoke"
    "forced"
    "hearing_impaired"
    "visual_impaired"
    "clean_effects"
    "attached_pic"
    "timed_thumbnails"
    "captions"
    "descriptions"
    "metadata"
    "dependent"
    "still_image"
  ]
}

def "nu-complete ffmpeg-discard" [] {
  [
    "none"
    "default"
    "noref"
    "bidir"
    "nokey"
    "all"
  ]
}

def "nu-complete ffmpeg-encoder" [] {
  ^ffmpeg -hide_banner -v quiet -encoders
  | lines
  | skip 2
  | where ($it | str trim) != ""
  | parse "{flags} {name} {description}"
  | get name
}

def "nu-complete ffmpeg-decoder" [] {
  ^ffmpeg -hide_banner -v quiet -decoders
  | lines
  | skip 2
  | where ($it | str trim) != ""
  | parse "{flags} {name} {description}"
  | get name
}

def "nu-complete ffmpeg-codec" [] {
  ([ "copy" ] | append (^ffmpeg -hide_banner -v quiet -codecs
  | lines
  | skip 2
  | where ($it | str trim) != ""
  | parse "{flags} {name} {description}"
  | get name))
}

def "nu-complete ffmpeg-format" [] {
  ^ffmpeg -hide_banner -v quiet -formats
  | lines
  | skip 4
  | where ($it | str trim) != ""
  | parse "{flags} {name} {description}"
  | get name
  | each { |x| $x | split row "," }
  | flatten
  | each { |x| $x | str trim }
  | uniq
}

# export extern "ffmpeg" [
#   ...args: string@"nu-complete ffmpeg-files"
#   -L
#   -h?: string@"nu-complete ffmpeg-help-topic"
#   -?: string@"nu-complete ffmpeg-help-topic"
#   -help: string@"nu-complete ffmpeg-help-topic"
#   --help: string@"nu-complete ffmpeg-help-topic"
#   -version
#   -buildconf
#   -formats
#   -muxers
#   -demuxers
#   -devices
#   -codecs
#   -decoders
#   -encoders
#   -bsfs
#   -protocols
#   -filters
#   -pix_fmts
#   -layouts
#   -sample_fmts
#   -dispositions
#   -colors
#   -sources: string
#   -sinks: string
#   -hwaccels
#   -loglevel: string@"nu-complete ffmpeg-loglevel"
#   -v: string@"nu-complete ffmpeg-loglevel"
#   -report
#   -max_alloc: string
#   -y
#   -n
#   -ignore_unknown
#   -filter_threads: string
#   -filter_complex_threads: string
#   -stats
#   -max_error_rate: string
#   -f: string@"nu-complete ffmpeg-format"
#   -c: string@"nu-complete ffmpeg-codec"
#   -codec: string@"nu-complete ffmpeg-codec"
#   -pre: string
#   -map_metadata: string
#   -t: string
#   -to: string
#   -fs: string
#   -ss: string
#   -sseof: string
#   -seek_timestamp
#   -timestamp: string
#   -metadata: string
#   -program: string
#   -target: string@"nu-complete ffmpeg-target"
#   -apad
#   -frames: string
#   -filter: string
#   -filter_script: string@"nu-complete ffmpeg-files"
#   -reinit_filter
#   -discard: string@"nu-complete ffmpeg-discard"
#   -disposition: string@"nu-complete ffmpeg-disposition"
#   -vframes: string
#   -r: string
#   -fpsmax: string
#   -s: string
#   -aspect: string
#   -display_rotation: string
#   -display_hflip
#   -display_vflip
#   -vn
#   -vcodec: string@"nu-complete ffmpeg-encoder"
#   -timecode: string
#   -pass: string
#   -vf: string
#   -b: string
#   -dn
#   -aframes: string
#   -aq: string
#   -ar: string
#   -ac: string
#   -an
#   -acodec: string@"nu-complete ffmpeg-encoder"
#   -ab: string
#   -af: string
#   -sn
#   -scodec: string@"nu-complete ffmpeg-encoder"
#   -stag: string
#   -fix_sub_duration
#   -canvas_size: string
#   -spre: string
# ]

def "nu-complete ffmpeg-files" [] {
  ls
  | get name
}
