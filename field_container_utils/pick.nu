export def main [...rest] {
	use kv_utils/ * ;
	use cellpath_utils.nu  * ;
	use ./deep.nu *;

	let input = $in ;

	$rest
	| each {|n| $input | get $n  | each { {key: $n, value: $in} } }
	| where { is-not-empty }
	| from kv
}
