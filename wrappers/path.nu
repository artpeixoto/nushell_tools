export def "path stem" [] {
	$in | path parse | 	get stem
}
