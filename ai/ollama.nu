export const env_config_path: cell-path = $.ai.ollama;

export const defaults = {
	embedding: {
		model: "embeddinggemma"
	},

}
def --wrapped "inner_ollama_exe" [...rest] {
	load_vendor_env ;
	^ollama ...$rest
}

def --wrapped "inner_ollama_web" [path: string, headers?: record ...rest] {
	use ../field_container_utils/ * ;
	let auth = auth get;
	let protocol = if $auth.uses_tls { "https://" } else { "http://" };

	mut default_headers = {};
	if ( $auth.key? | is-not-empty ) {
		$default_headers.Authorization = $"Bearer ($auth.key)"
	}

	let headers = (
		$headers
		| default --deep $default_headers
	);

	$in
	| to json
	| tee {log debug $"request: ($in)"}
	| ( http post $"($protocol)( $auth.host )($path)"
	    --pool
		--headers $headers
		--raw
  	)
    | tee {log debug $"response: ( $in )" }
    | from json
}

def --env "load_vendor_env" [] {
	let auth =  auth get;

  	{
	   OLLAMA_HOST: $auth.host? ,
	   OLLAMA_API_KEY: $auth.key?
   	}
    | compact
    | load-env
    ;
}

export def "auth get" [] {
	let auth =  (
		$env
		| get $env_config_path --optional
		| default {error make "ai env variables not initialized" }
		| $in.auth?
		| default {error make "auth not found. did you initialize" }
 	);

  	return $auth
}


export def --wrapped "ls" [...rest] {
	( inner_ollama_exe ls ...$rest
	| from ssv
	| rename --block {str snake-case}
	)
}

export def --env "ollama auth load" [--host: string, --key: string, --uses_tls = false, --no_export_vendor = false] {
	use ../kv_utils/ *;
	use ../field_container_utils/ * ;
	use ../cellpath_utils.nu *;
	let auth_value =  (
		{
			host: $host,
			uses_tls: ($uses_tls | default true),
			key: $key
		}
		| compact
		| wrap auth
	);

	$env
	| pick ($env_config_path | cellpath optional)
	| upsert --deep $env_config_path $auth_value
	| tee { log info $"loading ollama env: \n($in | table -e)" }
	| load-env $in;

	let export_vendor = ( not $no_export_vendor ); # for the sake of clarity
	if ($export_vendor) {
		load_vendor_env;
	}
}

export def --env "ollama auth load --local" [--no_export_vendor = false] {
	use kv_utils/ *;
	let host = "localhost:11434"


	ollama auth load  --host $host --uses_tls false --no_export_vendor $no_export_vendor
}

export def --env "ollama auth load --cloud" [--no_export_vendor = false] {
	use kv_utils/ *;
	let key = (
		open $"($env.HOME)/.local/auth/ollama.auth.pgp"
		| gpg --decrypt
	);
	let host = "ollama.com"


	(ollama auth load
		--host $host
		--key $key
		--uses_tls true
		--no_export_vendor $no_export_vendor
	)
}



export def --wrapped "ollama ps" [...rest] {
	( inner_ollama_exe ps ...$rest
	| from ssv
	| rename --block {str snake-case}
	)
}


export def "ollama stop --all" [] {
	inner_ollama_exe ps
	| each {inner_ollama s_exetop $in.name}
}

export def "ollama chat" [--model: string, --prompt: string, --history: table, --window_size: int = 10] {
	let model = $model 	 | default {  error make "model must be informed" }
	let prompt = $prompt | default "youre a helpful assistant";
	mut history = [...( $history | default []) , {role: user, content: $in}] | last ($window_size + 1);

	let request = {
		model: $model,
		stream: false,
		messages: [{role: system, content: $prompt}, ...$history]
	};

	let auth = $env.$env_config_path;
	error make "todo"
	let response = (
		ollama run
	);

	$history ++= [$response];

	return {out: $response.content, next: $history}
}

export def "ollama embed" [ --dimensions: int, --model: string ] : [
	string -> list<float>
] {
	use ../field_container_utils/ * ;
	let parms = (
		{ model: $model, dimensions: $dimensions }
		| compact
		| default --deep $env.ai?.embeddings?
		| default --deep {
			model: "embeddinggemma",
			dimensions: 1024,
		}
	);

	inner_ollama_exe run $parms.model $in --dimensions $parms.dimensions
	| from json
}

export def "ollama run" [
	--model: string,
	--prompts: oneof<string, list<string>>,
	--images: list<binary>,
	--web-search    = false,
	--show-thinking = false,
] : [
	list<string> -> string,
	table -> string,
	string -> string,
] {
	use ../json/;
	use ../cond_utils/ * ;
	use ../type_utils/  * ;
	use ../cmp_utils/ * ;

	let model = $model | default {  error make "model must be informed" }

	let prompts = (
	 	[ $prompts ]
		| flatten
		| default --empty  ["youre a helpful assistant"]
		| each {{role: system, content: $in}}
	);

	let input = [ $in ] | flatten | each where { typeof | neq "record" } {{role: user, content: $in}} ;

	let request = {
		model: $model,
		messages: [...$prompts, ...$input],
		# format: $format
		stream: false,
	}
	| compact;

	log debug $"request: ($request)";

	let auth = auth get;
	mut headers = {};
	if ( $auth.key? | is-not-empty ) {
		$headers.Authorization = $"Bearer ($auth.key)"
	}

	let response = (
		$request
		| inner_ollama_web "/api/chat"
		| get message.content

		# | reject role
	);


	return $response
}