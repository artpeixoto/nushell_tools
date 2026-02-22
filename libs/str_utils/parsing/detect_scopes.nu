use ../is_empty_or_whitespace.nu ; 
export def main [surrounders: table<start: string, stop: string> ] {
	mut input = $in ;
	mut parents = []; 
	mut res = { start: null, elements: [], stop: null }; 
	mut current_content = "";
	let last_index = $input | str length ;
	mut index = 0;

	def get_starts_with_surrounder [els] {  let input = $in ; $els | enumerate  | where {|el| $input | str starts-with $el.item } | get index | first }

	loop {
		if ($index >= $last_index) {
			break 
		}

		let string = $input | str substring ($index..); 	

		# check if is start
		let surrounder_ix = $string | get_starts_with_surrounder ($surrounders | get start); 
		if $surrounder_ix != null {
			let surrounder = $surrounders | get $surrounder_ix;
			if ( $current_content | is_empty_or_whitespace | not $in ) {
				$res.elements ++= [{type: content, value: $current_content}];
				$current_content = "";
			}
			$parents ++= [$res]
			$res = {start: $surrounder.start ,  elements: [],  stop: $surrounder.stop};
			$index += ($surrounder.start | str length) ; 
			continue;
		} else if  ( $res.stop != null ) and ($string | str starts-with $res.stop) {
			let stop = $res.stop;
			mut parent = $parents | last ;

			if ( $current_content | is_empty_or_whitespace | not $in) {
				$res.elements ++= [{type: content, value: $current_content}];
				$current_content = "";
			}

			$parent.elements ++= [{type: scope, value: $res}] ; 
	
			$res = $parent;
			$parents = $parents | drop 1 ; 
			$index += ($stop | str length) ;
			continue;
		} else {
			$current_content += $string | str substring ..0 ; 
			$index += 1;
			continue;
		}
	}
	if ($parents | is-not-empty) {
		erro make {msg: "there are remaining unclosed motherfuckers"}
	}

	return $res.elements
}