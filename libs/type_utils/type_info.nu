export def main [] {
	let input_type = $in | describe --detailed;
	def get_type_info_from_name [] {
		let input_type = $in;
		if ( $input_type in [ "bool","int","float","string","path","cell-path","binary","datetime","duration","filesize","glob", "nothing", 'range' ]  ) {
			return {type: $in.type, kind: "value" }
		} else if $input_type == "closure" { 
			return {type: "closure", kind: "code" }
		} else {
			let type = $input_type | parse "{major}<{inner}>" | get 0 -o ;
			match $type.major {
				"list" => {
					let inner_type_info = $type.inner | get_type_info_from_name ;
					return {type: "list", kind: "composed", inner: $inner_type_info }
				}
				"table" => {
					let inner_type_info = $"record<($type.inner)>" | get_type_info_from_name ;
					return {type: "list", kind: "composed", inner: $inner_type_info}
				}
				"record" => {
				}
				"oneof" => {
				}

			}
		}
	}
}



export def sketch [] {
	[[a,b];[1,{c: fuck}],[3,{c: dick}]] | describe | split chars | let chars;

	let depths =  ($chars | scan 0 {|next, acc| match $next { '<' => {$acc + 1}, '>' => {$acc - 1}, _ => {$acc}}}) ;
	let chars = $chars | wrap char | merge ($depths | wrap depth) | where $it.char not-in ['<', '>'];
	let chunks = $chars | chunk-by {get depth} | each {|el| let content = $el | get char | str join; let depth = $el.depth | first ; {text: $content, depth: $depth}}
}

export def read_type [] { 
	
}