alias original_which = which ; 



export def "main --single" [application: string] : [nothing -> string] {
	return (original_which $application)  | get path | first
}
export alias "main -s" = main --single ;
