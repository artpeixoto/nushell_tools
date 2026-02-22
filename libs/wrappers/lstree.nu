export def main [path = "."] {
	^lstree $path | from ssv
}