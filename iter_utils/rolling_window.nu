export def main [window_size: int] {
	($in
	| ( generate {|e,  acc|
		mut acc = $acc
		while ( ( $acc | length  ) >= $window_size) {
			$acc = $acc | skip 1
		}
		$acc = $acc ++ [$e];
		{out: $acc, next: $acc}
	} [])
	)
}
