export def --wrapped main [...rest] {
 ( sudo tshark -T tabs  -x --print
 | split row "\n\n"
 | chunks 2
 | each {|data|
		 let metadata = $data.0 | split column "\t" | rename index timestamp sender _ receiver protocol | reject _ | first;
		 let content = $data.1 | lines |  parse "{_}  {bytes}   {_}" | get bytes | str join | str replace " " "" --all  | decode hex;
		 return {...$metadata, content: $content}
 	}
 )
}
