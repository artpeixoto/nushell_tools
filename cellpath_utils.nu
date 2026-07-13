export module cellpath {
    export const zero = $.;

    export def "from any" [] : [] {
    	use ./type_utils/mod.nu  *;
	    let input = $in
	    match ( $input | typeof ) {
			"cell-path"	 => {
				$input
			},
			"string" => {
				$input
				| split row "."
				| into cell-path
			},
			"int" => {
				[ $input ]
				| into cell-path
			}
			"list" => {
				$input
				| flatten --all
				| each {from any}
				| flatten
				| from details
			},
			"table" => {
				$input
				| from details
			},
			$a => {error make $"cant make cellpath from ($a)"}
		}
    }

    export def "coerce" [] : [
	   	oneof<cell-path, string> -> cell-path
    ] {
       	use ./type_utils/mod.nu  *;
	    let input = $in
	    match ( $input | typeof ) {
			"cell-path"	 => {
				$input
			},
			"string" => {
				$input
				| split row "."
				| into cell-path
			},
			$a => {error make $"invalid type ($a) was expecting cell-path or string"}
		}
    }

    export def "optional" [] {
    	$in | details | update optional true | from details
    }

    export def details [] : [
    	oneof<cell-path, string> -> table<value: oneof<string>, optional: bool, insensitive: bool>
    ] {
	   	$in | coerce | split cell-path
    }

    export def "into string" [] : [
    	cell-path -> string
    ] {
	    use ./cmp_utils/ * ;
     	$in
      	| %into string
       	| str replace --regex '^\$\.' ''
    }

    export def "from details" [] : [
   		record<value: string, optional: bool, insensitive: bool> -> cell-path
   		record<value: int, optional: bool, insensitive: bool> -> cell-path
    	table<value: string, optional: bool, insensitive: bool>  -> cell-path
    	table<value: int, optional: bool, insensitive: bool>  -> cell-path
    ] {
        [$in] | flatten | into cell-path
    }

    export def components [] : [oneof<cell-path, string> -> list<cell-path>] {
        $in | details | each {[$in] | from details}
    }

    export def join [...paths: oneof<cell-path, string>] : [
        nothing -> cell-path,
        list<oneof<cell-path, string>> ->  cell-path,
        oneof<cell-path, string> -> cell-path,
    ] {
        let arg_paths = $paths   ;
        let pipe_paths = $in | default [] | [$in] | flatten  ;

        [$arg_paths, $pipe_paths]
        |	flatten
        |	each { into cell-path | split cell-path }
        |	flatten
        |	into cell-path
    }


    # export def "to string" []


    export def "parent" [--count = 1] : [
    	oneof<cell-path, string> -> cell-path
    ] {
    	$in
     	| components
      	| drop $count
        | join
    }

    export def "parents" [] : [
      	oneof<cell-path, string> -> list<cell-path>
    ] {
       	mut res = [];
        mut current = $in | coerce | components;

        while ($current | is-not-empty ) {
        	$current = $current | drop 1;
         	$res ++= [($current | join)];
        }

        $res
    }

    export def "is child" [parent : oneof<cell-path, string>] : [
	   	oneof<cell-path, string> -> bool
    ] {
   	 	let child_components =  $in | components;
	    let parent_components = $parent | components ;

		#cant have a child smaller than their parent
		if (( $child_components | length  ) <= ($parent_components | length) ) {
			return false ;
		}

		$child_components
		| zip $parent_components
		| all {|p| $p.0 == $p.1}
    }
}
