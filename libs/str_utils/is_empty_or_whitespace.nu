
export def 'str is_empty_or_white' [] : [string -> bool] {
	$in | split chars | all {$in in ["\n", "\t", "\r", " "]}
}