use std/assert;
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
   