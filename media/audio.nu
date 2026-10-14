use whisper_cpp/;
use std/log;
use kv_utils  *;
use type_utils/ * ;

export def "audio open" [] : [path -> record<content: binary, metadata: record>] {
    let path = $in | path expand;
    log info $"opening audio at ($path)";
    let ext = $path | path parse | get extension;


    let content = open $path --raw;
    return {
        content: $content,
        metadata: {
            type: $ext
        }
    }
}

export def "audio convert" [to: string] : [
    record<content: binary, metadata: record> -> record<content: binary, metadata: record>
] {
     $in
     | get content
     | ffmpeg -i - -f $to -
     | {content: $in, metadata: {type: $to}}
}

export def "audio save_temp" []: [record<content: binary, metadata: record> -> string] {
    let file = $in;
    let path = ignore |  mktemp --suffix ( $".( $file.metadata.type )" ) --dry;
    $file.content |  save $path --raw;

    $path
}
export def --wrapped "audio transcribe many" [...params] : [
    table<
        content: binary,
        metadata: record
    > -> list<table< text: string, time: record >>
] {
    let input = $in;
    let server_job = job spawn { whisper_cpp server start };
    try {
        $input
        | par-each --keep-order --threads 4 {
            whisper_cpp transcribe
            | tee {log info $"trancription: ($in.text)" }
        }
    } catch {|err|
        error make $err
    } finally {
        try {job kill $server_job}
    }
}



# export def --wrapped "audio transcribe many" [...params] : [
#     table<
#         content: binary,
#         metadata: record
#     > -> list<table< text: string, time: record >>
# ] {
#     let srcs = $in ;
#     if ($srcs | length | $in == 0) {
#         return []
#     }
#     let src_paths = ( $srcs | each { audio save_temp } );
#     log info $"transcribing audios: ( $src_paths | to json )";
#     let dest_path = mktemp --directory ;
#     whisper ...$params --output_format json --output_dir $dest_path ...$src_paths ;

#     let outputs = (
#         ls $dest_path  --full-paths
#         | where type == file
#         | each {|p|
#             let key = ( $p.name | path parse | get stem);
#             let value = (
#                 open $p.name --raw
#                 | from json
#                 | get segments
#                 | each {
#                     {   text: $in.text,
#                         time: {
#                             start: ( $in.start | into float | 1sec * $in )
#                             end: ( $in.end | into float | 1sec * $in)
#                         }
#                     }
#                 }
#             );
#             {key: $key, value: $value}
#         }
#         | from kv
#     );

#     $src_paths
#     | each {|src_path|
#         let src_name = $src_path  | path parse | get stem;
#         let out = $outputs | get $src_name;
#         $out
#     }
# }

export def "audio transcribe" [--lang = pt] : [
    record<
        content: binary,
        metadata: record
    > -> record<
        text: string, time: record
    >
] {
    [$in] | audio transcribe many | first
}
