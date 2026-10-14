use nu_plugin::{EngineInterface, EvaluatedCall, PluginCommand};
use nu_protocol::{Category, Example, LabeledError, PipelineData, Signals, Signature, Type, Value};

use crate::PestPlugin;

pub struct Parse;

impl PluginCommand for Parse {
    type Plugin = PestPlugin;

    fn name(&self) -> &str {
        "parse"
    }

    fn signature(&self) -> Signature {
        Signature::build(self.name())
            .switch("shout", "(FIXME) Yell it instead", None)
            .input_output_type(Type::List(Type::String.into()), Type::List(Type::String.into()))
            .category(Category::Experimental)
    }

    fn description(&self) -> &str {
        "(FIXME) help text for parse"
    }

    fn examples(&self) -> Vec<Example> {
        vec![
            Example {
                example: "[ Ellie ] | parse",
                description: "Say hello to Ellie",
                result: Some(Value::test_list(vec![
                    Value::test_string("Hello, Ellie. How are you today?")
                ])),
            },
            Example {
                example: "[ Ellie ] | parse --shout",
                description: "Shout hello to Ellie",
                result: Some(Value::test_list(vec![
                    Value::test_string("HELLO, ELLIE. HOW ARE YOU TODAY?")
                ])),
            },
        ]
    }

    fn run(
        &self,
        _plugin: &PestPlugin,
        _engine: &EngineInterface,
        call: &EvaluatedCall,
        input: PipelineData,
    ) -> Result<PipelineData, LabeledError> {
        let span = call.head;
        let shout = call.has_flag("shout")?;
        Ok(input.map(move |name| {
            match name.as_str() {
                Ok(name) => {
                    let mut greeting = format!("Hello, {name}. How are you today?");
                    if shout {
                        greeting = greeting.to_uppercase();
                    }
                    Value::string(greeting, span)
                }
                Err(err) => Value::error(err, span),
            }
        }, &Signals::empty())?)
    }
}

// #[test]
// fn test_examples() -> Result<(), nu_protocol::ShellError> {
//     // use nu_plugin_test_support::PluginTest;

//     // This will automatically run the examples specified in your command and compare their actual
//     // output against what was specified in the example.
//     //
//     // We recommend you add this test to any other commands you create, or remove it if the examples
//     // can't be tested this way.

//     // PluginTest::new("pest", PestPlugin.into())?
//     //     .test_command_examples(&Parse)
// }
