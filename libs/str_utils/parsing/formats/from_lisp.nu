use ../detect_scopes.nu ; 
export def main [] {
	let input = $in; 
	let scopes = $in | detect_scopes [[start, stop]; [ '(',')'], ] ;

	def transform_inner [] {
		let input = $in; 
		mut res = []
		for el in $input.elements {
			match $el.type { 
				"content" => {
					let value: string = $el.value ;					
					let items = $value | split row ' '; 
					$res ++= $items;
				},
				"scope" => {
					let elements = $el.value | transform_inner ;
					$res ++= [$elements]
				}	
			}
		}
		return $res
	}


	$scopes | transform_inner 
}