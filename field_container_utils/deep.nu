use ../type_utils/type_check.nu * ;

export def "rename --deep" [renamer: closure] : [any -> any] {
    mut renamed = $in | rename --block $renamer  ;
    let cols = $renamed | columns ;

    for col in $cols {
        $renamed = $renamed | update $col {
            let field = $in ;
            if ($field | is_field_container) {
                $field | rename --deep $renamer
            } else {
                $field
            }
        }
    }

    $renamed
}


export def "upsert --deep" [path: oneof<oneof<cell-path, string>, nothing>, value: record] {
	use ../kv_utils/ * ;
	use ../cellpath_utils.nu  * ;
	let path = if ( $path == null ) { $. } else {$path}

	let value_kvs =   (
		$value
		| into kv --deep
		| update key { each {
			[ $path, $in ]
			| cellpath join
		}}
	);

	$in | into kv --deep | where { $in.key not-in $value_kvs } | append $value_kvs | from kv
}

export def "default --deep" [ value: oneof<record, nothing> ] : [
	oneof<record, nothing> -> record
] {
	use kv_utils/ * ;
	use cellpath_utils.nu  * ;

	let value_kvs = (
		$value
		| default {}
		| into kv --deep
	);

	let input_kvs = (
		$in
		| default {}
		| into kv --deep
	 );

	let to_add = $value_kvs | where key not-in $input_kvs.key;

	$input_kvs
	| append $to_add
	| from kv
}

export def "wrap" [path: cell-path] {
	use kv_utils/ * ;

	{key: $path, value: $in } | from kv
}
