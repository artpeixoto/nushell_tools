def --wrapped original_cargo [...rest] {
	let cargo_path = which cargo | get path | first ; 
	run-external $cargo_path ...$rest
}

export def --wrapped "cargo info" [crate_name: string, ...rest] {
	let lines = original_cargo info -v $crate_name ...$rest | collect | lines
	let first_line = $lines | get 0 | split row " "
	let name = $first_line | first 
	let tags = $first_line | skip 1 | where {str starts-with '#'} 

	let simple_prop_regex = '^(?P<key>\w+)\s*:\s*(?P<value>.+)$'
	let description_lines = $lines | skip 1 | take while { $in not-like $simple_prop_regex}
	let description = $description_lines | str join " ";
	let remainder_lines = $lines | skip (1 + ($description_lines | length)) | take while {$in like $simple_prop_regex}
	
	let remainder = $remainder_lines	 | str join "\n" | parse --regex $simple_prop_regex | transpose --header-row --as-record

	let features_lines = $lines | skip ( 1 + ($description_lines | length)  + ($remainder_lines | length));
	let features_lines = $features_lines | skip until {$in | str trim | str starts-with "features"}
	let features_values = $features_lines | skip 1 | where {str starts-with " "} | each {parse --regex '^ (?P<active_marker>[ \+])(?P<feature_name>\w+([-_]\w)*)\s*=\s*\[(?P<values>.*)]\s*$'}
	let features = $features_values | flatten | each {
		let values = $in
		let is_active = $values.active_marker == "+"
		let feature_name = $values.feature_name
		let feature_activations = $values.values | split row "," | each {str trim}

		return {
			key: $feature_name,
			data: {
				is_active: $is_active,
				activations: $feature_activations
			}
		}
	} | transpose --header-row --as-record

	return {
		name: $name,
		tags: $tags,
		description: $description,
		...$remainder
		features: $features
	}
}
