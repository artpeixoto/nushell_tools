use ../type_utils/  *;

export def "into kv" [
    --key_path (-k) : oneof<string, cell-path>   = key,
    --value_path (-v) :oneof<string, cell-path>  = value
] : [any -> table<key: string, value: any>] {
    let input = $in ;

    $input | items {|k, v| ({ $key_path:  $k , $value_path: $v}) }
}

export def "into kv --deep" [] : [any -> table<key: string, value: any>] {
	use std-rfc/iter recurse;
	use ../cellpath_utils.nu *;
	let all = $in | recurse | rename key value;
	let parents = $all | get key | each { cellpath parent } | uniq;

	$all
	| where key not-in $parents
}

export def "from kv" [
    --key_path   (-k) : oneof<string, oneof<cell-path, int>> = key,
    --value_path (-v) : oneof<string, oneof<cell-path, int>> = value
] : [
	list -> record,
	table -> record,
	record -> record
] {
    mut res = {}
    let input = $in ;

    for item in $input {
        let value = $item | get $value_path ;
        let key   = $item | get $key_path;

        $res = $res | upsert $key $value ;
    }

    $res
}


export def "from kv --list" [] : [
    list<list> -> record
] {
    mut res = {}
    for item in $in {
        $res = $res | merge ($item.1 | wrap $item.0) ;
    }

    $res
}
