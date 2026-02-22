/**
 * @file SampleGrammar grammar for tree-sitter
 * @author ass-eater
 * @license MIT
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

export default grammar({
	name: "sample_grammar",
	extras: ($) => [
		/\s*/
	] ,
	rules: {
		source_file: ($) => $.type,
		type: ($) => choice( $.composed_type, $.value_type ),
		composed_type: ($) => choice(
			$.list_type,
			$.oneof_type,
			$.record_type,
			$.table_type,
		) ,
		list_type: ($) => seq("list", "<", $.type, ">"),
		oneof_type: ($) => seq("oneof", "<", $.type, $.type, ">") 		,
		record_type: ($) => seq("record", "<", seq($.field_defn, repeat(seq(",", $.field_defn))), ">"),
		table_type: ($) => seq("table", "<", seq($.field_defn, repeat(seq(",", $.field_defn))), ">"),

		field_defn: ($) => seq($.ident, ":", $.type),
		ident: ($) => choice(/[a-zA-Z_][a-zA-Z0-9_]*/, /\"(.)+\"/),
		value_type: ($) => choice( "bool", "path", "string", "int", "nothing" , "float", "binary", "duration", "datetime")
	}
})

