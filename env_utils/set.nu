use ../type_utils/ *;
use ../kv_utils/ * ;
export def --env  main [name: oneof<cell-path, string>, value: oneof<record, any> ] {

	let name = match ($name | typeof) {
		
	}
	if ($value | is record ) {
		$value
	} else {
		
	}
}

def --env inner [name] {
	
}