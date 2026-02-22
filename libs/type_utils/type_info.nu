export def main [] {
	let input_type = $in | describe --detailed;
	def get_type_info_from_name [] {
		let input_type = $in;
		if ( $input_type in [ "bool","int","float","string","path","cell-path","binary","datetime","duration","filesize","glob", "nothing" ]  ) {
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