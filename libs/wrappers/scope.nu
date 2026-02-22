export def "scope executables" [] : [nothing -> table<command: string, path: string, type: string> ] {
	which -a | where type == external | collect
}
