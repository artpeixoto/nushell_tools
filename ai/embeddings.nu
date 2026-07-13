

export def generate [] : [
	string -> record<elements: list<float>, magnitude: float>
] {
	use  ollama.nu *;
	$in
	| ollama embed
	| flatten
	| from_raw
}

export def magnitude [] {
    dot_prod $in $in | math sqrt
}

export def from_raw [] : [list<float> -> record] {
	let elements = $in;
	let magnitude = $elements | magnitude;
    {
	     elements: $elements,
	     magnitude: $magnitude
    }
}

export def dot_prod [a: list<float>, b: list<float>]: [nothing -> float] {
	$a | zip $b
	| each {$in.0 * $in.1}
	| math sum
}

export def similarity [a, b] {
	((dot_prod $a.elements $b.elements) / ($a.magnitude * $b.magnitude))
}

export def search [ question: string, make_answer: closure ] {
	let question_embedding = $question | generate;

	$in
	| wrap element
	| par-each --keep-order {insert embedding {
		get element
		| do $make_answer
		| generate
	} }
	| insert similarity {
		get embedding
		| similarity $in $question_embedding
	}
	| sort-by similarity --reverse
}

export def search-embeddings [ question_embedding: record, embedding_path: closure , --threshold: float = 0.5,] : [
	list<any> -> table<similarity: float, element: any>
] {

	enumerate
	| chunks 128
	|  par-each {
		each {
			let point = $in.item;
			let index = $in.index;

			let similarity = (
				$point
				| do $embedding_path
				| similarity $in $question_embedding
			);

			{ element: $point, similarity: $similarity, index: $index }
		}
	}
	| flatten
	| where { $in.similarity > $threshold }
	| tee { each { log info $"selected ($in.index)"; } }
	| sort-by similarity --reverse 
}
