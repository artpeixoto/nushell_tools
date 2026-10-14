use anyhow::{anyhow, bail};
use pest_meta::ast::{Rule, RuleType};
use pest_meta::optimizer::OptimizedRule;
use pest_vm::Vm;
use serde::{Deserialize, Serialize};
use serde_content::{Data, Value};
use tap::Pipe;

// pub struct PestPlugin;

// impl Plugin for PestPlugin {
//     fn version(&self) -> String {
//         // This automatically uses the version of your package from Cargo.toml as the plugin version
//         // sent to Nushell
//         env!("CARGO_PKG_VERSION").into()
//     }

//     fn commands(&self) -> Vec<Box<dyn PluginCommand<Plugin = Self>>> {
//         vec![
//             // Commands should be added here
//             Box::new(Parse),
//         ]
//     }
// }


use std::borrow::Cow;
use std::collections::HashMap;
use std::io::{Read, Write};
use std::path::Path;

use pest::error::{Error, ErrorVariant, InputLocation};
use pest::iterators::{Pair, Pairs};

use pest_meta::parser::{self, Rule as GrammarLangRule} ;
use pest_meta::{optimizer, validator};


fn format_pair(pair: Pair<&str>, indent_level: usize, is_newline: bool) -> String {
    let indent = if is_newline {
        "  ".repeat(indent_level)
    } else {
        String::new()
    };

    let children: Vec<_> = pair.clone().into_inner().collect();
    let len = children.len();
    let children: Vec<_> = children
        .into_iter()
        .map(|pair| {
            format_pair(
                pair,
                if len > 1 {
                    indent_level + 1
                } else {
                    indent_level
                },
                len > 1,
            )
        })
        .collect();

    let dash = if is_newline { "- " } else { "" };
    let pair_tag = match pair.as_node_tag() {
        Some(tag) => format!("(#{}) ", tag).into(),
        None => Cow::Borrowed(""),
    };
    match len {
        0 => format!(
            "{}{}{}{}: {:?}",
            indent,
            dash,
            pair_tag,
            pair.as_rule(),
            pair.as_span().as_str()
        ),
        1 => format!(
            "{}{}{}{}: {}",
            indent,
            dash,
            pair_tag,
            pair.as_rule(),
            children[0]
        ),
        _ => format!(
            "{}{}{}{}:\n{}",
            indent,
            dash,
            pair_tag,
            pair.as_rule(),
            children.join("\n")
        ),
    }
}

fn parse_grammar<'a>( grammar: &'a str,) -> Result<Vec<OptimizedRule>, anyhow::Error> {
    let result = parser::parse(GrammarLangRule::grammar_rules, grammar)
        .map_err(|error| error.renamed_rules(pest_meta::parser::rename_meta_rule));

    let pairs = match result {
        Ok(pairs) => pairs,
        Err(error) => { anyhow::bail!("{error:?}"); }
    };

    if let Err(errors) = validator::validate_pairs(pairs.clone()) {
         anyhow::bail!("{errors:?}");
        // return errors
        //     .into_iter()
        //     .map(|e| convert_error(e, grammar))
        //     .collect();
    }

    let ast = match parser::consume_rules(pairs) {
        Ok(ast) => ast,
        Err(errors) => {
            anyhow::bail!("{errors:?}");
            // return errors
            //     .into_iter()
            //     .map(|e| convert_error(e, grammar))
            //     .collect();
        }
    };

    Ok( optimizer::optimize(ast.clone()) )
}



fn run_on_input<'a>(input: &str, rules: &[OptimizedRule], root_rule_name: &str) -> Result<String, anyhow::Error> {
    let vm =  Vm::new(rules.into_iter().cloned().collect());
    let mut pairs = vm.parse(root_rule_name, input).map_err(|e| anyhow!("{e:?}"))?;
    let Some(pair) = pairs.next() else {bail!("No matches")};
    Ok(serde_json::to_string_pretty(&pair)?)
}


// fn build<'a>(
//     pairs: Pairs<'a, &'a str>,
//     rules: &'a HashMap<String, OptimizedRule>,
// ) -> impl IntoIterator<> {
//     for pair in pairs {
//         let pair_rule = &rules[pair];
//         match pair_rule.ty {
//             RuleType::Normal => {

//             },
//             RuleType::NonAtomic => todo!(),
//             RuleType::Silent => ,
//             RuleType::Atomic => todo!(),
//             RuleType::CompoundAtomic => todo!(),
//         }
//         // match pair_rule{
//         // }
//     }
// }



fn convert_error(error: Error<Rule>, grammar: &str) -> HashMap<String, String> {
    let message = match error.variant {
        ErrorVariant::CustomError { message } => message,
        _ => unreachable!(),
    };

    match error.location {
        InputLocation::Pos(pos) => {
            let mut map = HashMap::new();

            map.insert("from".to_owned(), line_col(pos, grammar));
            map.insert("to".to_owned(), line_col(pos, grammar));
            map.insert("message".to_owned(), message);

            map
        }
        InputLocation::Span((start, end)) => {
            let mut map = HashMap::new();

            map.insert("from".to_owned(), line_col(start, grammar));
            map.insert("to".to_owned(), line_col(end, grammar));
            map.insert("message".to_owned(), message);

            map
        }
    }
}

fn line_col(pos: usize, input: &str) -> String {
    let (line, col) = {
        let mut pos = pos;
        // Position's pos is always a UTF-8 border.
        let slice = &input[..pos];
        let mut chars = slice.chars().peekable();

        let mut line_col = (1, 1);

        while pos != 0 {
            match chars.next() {
                Some('\r') => {
                    if let Some(&'\n') = chars.peek() {
                        chars.next();

                        if pos == 1 {
                            pos -= 1;
                        } else {
                            pos -= 2;
                        }

                        line_col = (line_col.0 + 1, 1);
                    } else {
                        pos -= 1;
                        line_col = (line_col.0, line_col.1 + 1);
                    }
                }
                Some('\n') => {
                    pos -= 1;
                    line_col = (line_col.0 + 1, 1);
                }
                Some(c) => {
                    pos -= c.len_utf8();
                    line_col = (line_col.0, line_col.1 + 1);
                }
                None => unreachable!(),
            }
        }

        line_col
    };

    format!("({}, {})", line - 1, col - 1)
}

fn main(){
    let grammar_str = std::env::args().skip(1).next().expect("No grammar");
    let grammar = parse_grammar(&grammar_str).unwrap();
    let mut input = String::new();
    std::io::stdin().read_to_string(&mut input).unwrap();

    let parse_res = run_on_input(&input, &grammar, "main").unwrap();
    std::io::stdout().write_all(parse_res.as_bytes()).unwrap();
}
