use ../env_utils * ;
use ../kv_utils/ *;

export-env {
	let cargo_default_home = $nu.home-dir | path join ".cargo";
	default_env {
		cargo: {
			home: {
				path : $cargo_default_home,
			}
			bin: {
				path: ($cargo_default_home | path join bin)
			}
		}
	}
}

def --wrapped original_cargo [...rest] {
	let cargo_path = which cargo | get path | first ;
	run-external $cargo_path ...$rest
}

export def --wrapped "cargo info" [crate_name: string, ...rest] {
	^cargo info -v $crate_name
	| split row --regex '\n(?!\s+\S+)'
	| do {
	    use kv_utils/ *;
	    let lines = $in;
	    let name_header = $lines | get 0 | split row " " --number 2 ;
	    let name = $name_header.0
	    let tags = $name_header.1 | split row " " | parse --regex '#(?<tag>.+)'  | get tag;

	    let description = $lines.1;

	    mut remainder = (
	        $lines
	        | skip 2
	        | split column ':'    --number 2
	        | rename key value
	        | from kv
	    );

	    if ($remainder has features) {
	        $remainder.features = (
	            $remainder.features
	            | lines
	            | where { is-not-empty  }
	            | split column "="
	            | rename name activations
	            | each { update activations {from nuon} }
	        )
	    }
	    if ($remainder has dependencies) {
	        $remainder.dependencies = (
	            $remainder.dependencies
	            | lines
	            | where {is-not-empty}
	            | parse --regex '^ (?<active>\+| )(?<name>\w+?)@(?<version>.+)$'
				| each { update active {
					match $in {
						"+" => true,
						" " => false,
					}
				}}
				| move active --last
	        );
	    }

	    return {
	        name: $name
	        description: $description,
	        tags: $tags
	        ...$remainder
	    }
	}
}
