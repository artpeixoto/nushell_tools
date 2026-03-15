export def "split by_ident" [] : [string -> any] {
	def "str is_empty_or_whitespace" [] : [string -> bool] {
		$in =~ '^\s*$'
	}

	mut lines = $in | lines ;
	mut stack: list<record< content: any, children: list<any>>> = [];
	mut current = null;

	loop {
		let line = $lines | first ; 
		if $line == null {
			if ( $stack | is-empty ) {
				break 
			} else {

			}
		}
	}

	$current
}

