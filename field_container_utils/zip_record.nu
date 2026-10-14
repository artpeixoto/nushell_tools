use ../kv_utils/ * ;

export def "zip --record"  [input?: record ] : [
	record -> table
	nothing -> table
] {
		
	let input = $in | default $input ;
	let cols = $input | columns ;

	mut iterators = $input | get ($cols | first)  ;

	for col in ($cols | skip 1) {
		$iterators = $iterators | zip ($input | get $col);
	}

	let response = (
		$iterators | 
		each {|vals| ($cols | zip $vals) | from kv -k 0 -v 1 } 
	); 

	return $response;
}