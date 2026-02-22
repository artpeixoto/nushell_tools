export def main [] : [string -> bool] {
	$in | split chars | all {|c| $c in ["\n", "\t", "\r", " "]}
}