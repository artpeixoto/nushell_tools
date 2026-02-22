use ../detect_scopes.nu ; 
export def main [] : [] {
	
	let input = $in ; 
	let scopes = $in | detect_scopes [[start, stop]; [ '(',')'], ] | $in.0.value;

	def transform_inner [] {
		let input = $in; 
		let content = $input
		let header_raw = $input.elements.0.value ;
		let header = $input.elements.0.value | str trim | parse "{node_type} [{start_row}, {start_col}] - [{end_row}, {end_col}]" | first;

		mut res = { 
			type: $header.node_type,
			span: {
				start: {line: $header.start_row, column: $header.start_col}
				end: {line: $header.end_row, column: $header.end_col}
			},
			children: [] 
		}; 

		for el in ( $input.elements | skip 1) {
			match $el.type { 
				"content" => {
					$res.children ++= [ $el.value ] ;
				},
				"scope" => {
					let elements = $el.value | transform_inner ;
					$res.children ++= [$elements]
				}	
			}
		}
		return $res
	}

	$scopes | transform_inner 
}