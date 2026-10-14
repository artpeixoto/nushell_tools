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
	    let tags = $name_header.1? | each { $in | split row " " | parse --regex '#(?<tag>.+)'  | get tag } | default {[]} ;

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
				| update name { str substring 1.. }
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

export module nu-complete {
    export def cargo-features [context?: string] {
        log info ($in | to nuon);

        $context
        | log info $"($in | to nuon)";

        cargo info ($context | split words | get 2)
        | get features --optional
        | get name
    }
}
use nu-complete;
export def --wrapped "cargo add"  [
    crate_name: string,
    --features (-f): list@"nu-complete cargo-features"
    ...rest
] {
    (^cargo add $crate_name
        --features ($features | str join " ")
        ...$rest
    )

}
