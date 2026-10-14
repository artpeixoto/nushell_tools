use ../kv_utils * ; 
use std/iter scan;
export def main [path = "."] {
	let sep = '    '
	let tag = random int;

	job spawn {
		^lstree $path | 
			lines | 
			each { 
				split row $sep | 
				wrap data | 
				job send 0 --tag $tag
			};
		{control: done} | job send 0 --tag $tag
	}
			
	let headers = job recv --tag $tag | get data ;

	0.. | 
	each {job recv --tag $tag} | 
	take while {$in != {control: done}} | 
	get data | 
	each {|row| 
		$headers | 
		zip $row | 
		from kv --list 
	} 
}