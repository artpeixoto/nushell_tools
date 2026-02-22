# rejects certain incoming values from the pipe.
export def main [rejected_values: list<any>] : [list<any> -> list<any>] {
	$in  | where {$in not-in $rejected_values}
}