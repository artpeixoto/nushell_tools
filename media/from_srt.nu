export def "from srt" [] {

	( $in
	| split row "\n\n"
	| parse --regex '\A(?<index>\d+)\n(?<start_timestamp>[0-9:,]+) --> (?<end_timestamp>[0-9:,]+)\n(?<content>\O*\z)'
	)
}

export def "to srt" [] : [
	table<index: int, start_timestamp: string, end_timestamp: string, content: string> -> string
] {
	( $in
	| each { $"( $in.index )\n($in.start_timestamp) --> ($in.end_timestamp)\n($in.content)\n" }
	| str join "\n"
	)
}
