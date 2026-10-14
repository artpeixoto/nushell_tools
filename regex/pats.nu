use ../type_utils/ * ;
export def group [ pat?: string, --capture (-c): oneof<bool, string> = false] {
	let inner: string = $pat | default $in |  default { error make "no input" } ;
	match $capture {
		false => $"\(?:($in)\)",
		true => $"\(($in)\)",
		$a if ($a | is string ) => {
			$"\(?<($a)>($in)\)"	
		}
		$a => { error make $"could not understand value of type ($a | typeof)" } 
	}
}

export alias g = group;

export module word {
	export def boundary [] { "(?:\\b)" }
	export module boundary {
		export def not [] { 
			"(?:\\B)"
		}	
		export def start [] {
			"(?:\)"

		}
		export def end [] {

		}
	}

	export def char [] {
		'(?:\w)'
	}
	export def not [] {
		'(?:\W)'
	}
}

export def word [] {
	'(?:\w+)'
}

export def digit [] {

}

export module num {
	export def int [] {

	}
	

}



export def email [] {
  '(?:[\w-\.]+@([\w-]+\.)+[\w-]{2,4})'
}

export def any [] {

}


export module space  {
	export def not [] {

	}
	export def tab
}





export const newline = "(?:\n\r|\n)";
export const space = "(?:\\s)";
export const spaces = "(?:\\s+)" ;
export const alpha = "(?:\\a)"
export const ident = "(?:)"
export const base64 = "(?:(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?)";


# export const word