use ../iter_utils/rolling_window.nu ;
use ./ollama.nu *;
export const default_translator_model = "gemma4:31b";

 export-env {
	$env.ai.translate.model = $env.ai?.translate?.model? | default $default_translator_model
};

export def main [--to_lang = portuguese, --extra_prompt: string ] {
	( $in
	| tee {log debug $"translating ($in) to ($to_lang)"}
	| ( ollama run
		--model $default_translator_model
		--prompts $"You are now a skillful translator. Translate the user input to the language ($to_lang) exactly as it is. Output only the translation, without commentaries or markdown. Do notice you are being used in an automation, so do not output commentary. If you have any questions, try to solve them yourself. ($extra_prompt)"
	)
	| tee {log debug $"output is: ($in)"}
	)
}

export def many [--to_lang = portuguese,  --ctx_size = 4] : [list<string> -> list<string>] {
	use ollama.nu *;

	def generate_tail [head_start: int, tail_size: int] {
		let tail_start = $head_start - $tail_size | [$in 0] | math max;
		let tail_end = $head_start
		return $tail_start..<$tail_end
	}

	let input = $in;
	let blocks = (
		$input
		| rolling_window ($ctx_size + 1)
		| each { | w|
            {
                tail: ($w | drop 1),
                head: ($w | last)
            }
		}
	);
	use ../json;




	$blocks
	| par-each --keep-order --threads  16 {|block|
		$block.head
		| ( ollama run
			--model $default_translator_model
			--prompts ([
				$"You are now a skillful translator. You must translate the user input to the following language: ($to_lang). Your output must consist solely of the translation in raw text, with no commentaries and no markdown. Previous entries have been added for context. You must translate ONLY the user input. Note you are being used in an automation, so if you have questions, try to solve them yourself.",
  				$"PREVIOUS ENTRIES: ($block.tail | to json)",
			])
		)
		| tee {  log info $"output is: ($in | to json)"  }
	}
}
