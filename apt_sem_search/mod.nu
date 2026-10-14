use ../ai;

export def "search" [
	query: string,
	--indexed_apt_db_path (-p) : path = "/mnt/Windows-SSD/Media/Databases/all_apts_indexed.ndjson"
] {
	let question_embedding = (
		$"The user is requesting a package that will help them: Here is their request: '($query)'. What package will help them?"
		| ai embeddings generate
	);

	open $indexed_apt_db_path --raw
	| lines
	| par-each { from json  }
	# | tee {each { log info ( $in.package ) } }
	| ( ai embeddings search-embeddings $question_embedding {get embedding} )
	| each {
		{...$in.element, similarity: $in.similarity}
	}
}
