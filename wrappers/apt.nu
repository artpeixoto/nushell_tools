use ../str_utils/ * ;


export  def --wrapped search [query: string, --count=10, ...rest] {
	^apt search $query ...$rest
    | parse_search_list
    | take $count
}


export def --wrapped list [...rest] {
	^apt list --verbose ...$rest
	| parse_search_list
}

export def --wrapped show [ ...rest] {
	^apt-cache show ...$in ...$rest
	| parse_prop_tables
}

def parse_prop_tables [] {
	use ../kv_utils/ * ;
	let newline_sep = "\\n" ;
	$in
		| split row $"\n\n"
	| par-each {
		let input = $in;
		try {

			let fields =   (
				$input
				| split row --regex "\n\r?(?!\\s+)"
				| where $it !~ "^\\w*$"
				| split column ":" --number 2
				| rename key value
			)
			if ($fields | any {$in  not-has value} ) {
				log error $"problem: ($fields | table -e)";
			}

			let fields = $fields | compact;

			let data = (
				$fields
				| from kv
				| rename --block {str snake-case}
			);

			return $data;
		} catch {|err|
			log error $"failed with ( $input ): ($err | to json)"
			error make "fuck";
		}
	}
}

def parse_search_list [] {
	$in
	| split row "\n\n"
    | each {
    	$in
     	| str replace "\n " " ||| "
     	| str replace "\n " " " --all
     	| lines  | last
    }
    | each { |raw|
		$raw
		| parse "{name}/{source} {version} {arch} ||| {description}"
		| first
    }
}
