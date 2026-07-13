use std/assert;
use ../kv_utils/ *;
use ../cond_utils/ * ;
def --wrapped inner_file [...rest] : [path -> any, list<path> -> list<any>] {
	$in | each { ^file ...$rest --brief -f - }
}
def assert_path_input [inp1: oneof<string, nothing>, inp2: oneof<string, nothing>] {
	let input = $inp1 | default $inp2	;
	assert not equal $input null
	return $input
}

export def --wrapped "file mime" [path?: path, ...rest] {
	let input = assert_path_input $path $in ;

	let res =  $input |
		inner_file --mime ...$rest |
		parse "{major_mime}/{minor_mime}; charset={charset}" |
		first ;

	return { major: $res.major_mime, minor: $res.minor_mime }
}

export def --wrapped "file charset" [path?: path, ...rest] {
	let input = assert_path_input $path $in ;

	let res =  $input |
		inner_file --mime ...$rest |
		parse "{major_mime}/{minor_mime}; charset={charset}" |
		first ;

	return  $res.charset
}

export def "file metadata" [ file_path?: oneof<glob, path> ] : [
] {
	let input = $in;
	let file_path = $file_path | default $input -e | default { error make {msg: "no input"} }

	let metadata =  (
        exiftool  -charset UTF8 -j -- $file_path
        | from json
        | first
        | rename --block {str snake-case }
        | reject --optional ...[ source_file exif_tool_version ]
        | into kv
        | each where {$in.key ends-with date} { update value  {into datetime}  }
        | from kv
	);
    return $metadata
 }

 export def "file content_id" [] : [path -> binary] {
 	let path = $in ;
  	let content = open $in --raw | into binary;
 	let length = $content | bytes length ;
  	let	hash = $content | hash md5 --binary  ;

   	return ( $hash  ++ (length  | into binary));
}
