export use ./from_srt.nu * ;

export def "stream extract subtitle" [ path: any ] {
	ffmpeg -i $path -c:s srt -f srt -
	| from srt
}
export def "stream inspect" [ path: path ] {
    ( ffprobe -i $path
        -show_streams
        -print_format json
    )
    | from json
    | get streams
}

export def "subtitle translate" [
    --parallelism = 12 ,
    --model = "gemma4:31b" ,
    --ctx_size = 3
] : [
    table<index: int, start_timestamp: string, end_timestamp: string, content: string> ->
    table<index: int, start_timestamp: string, end_timestamp: string, content: string>
] {
	use ../ai/ ;
	use ../parsers/ * ;
	use ../ai/ollama.nu *;
	use ../iter_utils/rolling_window.nu  ;

	ignore | ollama auth load --cloud ;

	let original = $in ;

	let ctx_size = 3;

	let default_translator_model = "gemma4:31b";

	let blocks = (
		$original
		| rolling_window ($ctx_size + 1)
		| each { | w|
            {
                tail: ($w | drop 1),
                head: ($w | last)
            }
		}
	);

	let to_lang = "portuguese";


	$blocks
    | par-each --keep-order --threads 12 {|block|
      		$block.head
            | insert translation {
                get content
                |  ( ollama run
         			--model $default_translator_model
         			--prompts ([
            				$"You are now a skillful translator. You must translate the user input to the following language: ($to_lang). Your output must consist solely of the translation in raw text, with no commentaries and no markdown. Entries have been added for context. You must translate ONLY the user input. Note you are being used in an automation, so if you have questions, try to solve them yourself.",
            				$"PREVIOUS ENTRIES: ($block.tail.content | to json)",
         			])
                )
            }
            | tee {log info ($in | to json) }
    }
 	| each {|entry| $entry | update content ($entry.translation) | reject translation}
}
