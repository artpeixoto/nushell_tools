export use ./from_srt.nu * ;

export def "video streams extract subtitle" [
] : [
    record -> table
] {
	get content
	| ffmpeg -i - -c:s srt -f srt -
	| from srt
}


export def "video streams extract frames" [
] : [
    record -> table
] {
    use ./image/ * ;

    let input = $in;

    let out_temp = mktemp --directory ;
    cd $out_temp;

    let input_file = $input | video save_temp;

    ffmpeg -r 1 -i $input_file -r 1 "frame_%08d.png"

    ;
    ls
    | get name
    | sort-by { parse "frame_{frame_num}.png" | get 0.frame_num | into int}
    | each {path expand}
}

export def "video metadata" [
    --frames,
    --packets
] : [
    binary -> record
] {
    let video = $in;
    let parms = [
        ...(if $frames { ["-show_frames"] } else {[]})
        ...(if $packets { ["-show_packets"] } else {[]})
    ]
    $in
    | ( ffprobe
        -i -
        # -show_error
        -show_format
        -show_streams
        -show_chapters
        ...$parms
        # -show_pixel_formats
        -output_format json
    )
    | from json
    | update format {update duration {into float | $in * 1sec}}
    | update streams { each { update duration {into float | $in * 1sec}} }
    | {
        ...$in.format,
        ...($in | reject format)
    }

}

export def "video streams info" [] : [
    record -> table
] {
    get content
    | ( ffprobe -i
        -show_streams
        -print_format json
    )
    | from json
    | get streams
    | each {update duration {into float | $in * 1sec} }
}

export def "video clip" [ range: record ] : [record -> record ] {
    let video = $in;    
    let start = $range | get start --optional | default {0ns};
    let end = $range | get end --optional | default {$video.metadata.duration};
    let start_parms  = [ -ss ($start / 1sec) ];
    let end_parms = [ -to ($end / 1sec) ]
    let out_path = mktemp --dry --suffix ($video.metadata.type | $".($in)");
    log info $"($start_parms) ($end_parms)"
    let video_path = $video | video save_temp ;

    $video.content 
    | ( ffmpeg
            -i $video_path
            ...$start_parms
            ...$end_parms
            $out_path
    );

    video open $out_path
}

export def "video open" [path?: path] : [ path -> record, nothing -> record ]   {
    use file/;
    let path = $in | default {$path} | default {error make "no path informed"} | path expand

    let mime = file mime $path ;
    if ($mime.major != video) { error make "not a video" ; return; }

    let content = open $path;
    let type = $path | path parse | get extension;
    let metadata = $content | video metadata;
    {
        content: $content,
        metadata: {
            type: $type,
            ...$metadata
        }
    }
}

export def "video save_temp" []: [record<content: binary, metadata: record> -> string] {
    let file = $in;
    let path = ignore |  mktemp --suffix ( $".( $file.metadata.type )" ) --dry;
    $file.content |  save $path --raw;

    $path
}

export def "video save" [path: path] : [record<content: binary, metadata: record> -> nothing] {
    let path = $path | path expand;
    let video = $in;
    let path = ( if ($path | path parse | get extension | $in != $video.metadata.type) {
        $path + "." + $video.metadata.type
    } else {
        $path
    } );

    $video | get content | save $path;
}

# export def "subtitle translate" [
#     --parallelism = 4 ,
#     --model = "gemma4:31b" ,
#     --ctx_size = 3
# ] : [
#     table<index: int, start_timestamp: string, end_timestamp: string, content: string> ->
#     table<index: int, start_timestamp: string, end_timestamp: string, content: string>
# ] {
# 	use ../ai/ ;
# 	use ../parsers/ * ;
# 	use ../ai/providers/ollama.nu  *;
# 	use ../iter_utils/rolling_window.nu  ;

# 	ignore | ollama auth load --cloud ;

# 	let original = $in ;

# 	let ctx_size = 3;

# 	let default_translator_model = "gemma4:31b";

# 	let blocks = (
# 		$original
# 		| rolling_window ($ctx_size + 1)
# 		| each { | w|
#             {
#                 tail: ($w | drop 1),
#                 head: ($w | last)
#             }
# 		}
# 	);

# 	let to_lang = "portuguese";


# 	$blocks
#     | par-each --keep-order --threads 12 {|block|
#   		$block.head
#         | insert translation {
#             get content
#             |  ( ollama run
#      			--model $default_translator_model
#      			--prompts ([
#         				$"You are now a skillful translator. You must translate the user input to the following language: ($to_lang). Your output must consist solely of the translation in raw text, with no commentaries and no markdown. Entries have been added for context. You must translate ONLY the user input. Note you are being used in an automation, so if you have questions, try to solve them yourself.",
#         				$"PREVIOUS ENTRIES: ($block.tail.content | to json)",
#      			])
#             )
#         }
#         | tee {log info ($in | to json) }
#     }
#  	| each {|entry|
#         $entry
#         | update content ($entry.translation)
#         | reject translation
#     }
# }
