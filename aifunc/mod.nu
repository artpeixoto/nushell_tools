


export def main [prompt: string, response_sample: any] : [any -> any] {
    use ../json;

    let input = $in | to json;
    let schema_input = (
        do {
            let format = $response_sample | json schema infer ;
            $format
        } |
        to json
    );

    let prompt = $"Resolve the following task. You response must be composed SOLELY of JSON. It should include no commentaries nor markdown. Follow output schema defined ahead. You may receive a list of inputs. In that case, your response must be a list, whose elements must, individually, match the schema.\n---\nTASK: ($prompt)\n---\nOUTPUT SCHEMA: ($schema_input)";

    $input | aichat $prompt | from json
}

export def generate_code [prompt: string, input_sample: any, response_sample: any ] : [nothing -> string] {
    use ../json;

    let output_info = (
        if $response_sample != null {
            {description: ( $response_sample | describe ), schema: ($response_sample | json schema infer )};
        } else {
            {description: "any", schema:{type: "json_object"}}
        }
    );

    $"export def main [] : [any -> ($output_info.description)]  {
    let input = $in ;
    let output_schema = ($output_info.schema) ;

    let base_prompt = \"Resolve the following task. You response must be composed SOLELY of JSON. It should include no commentaries nor markdown. Follow output schema defined ahead. You may receive a list of inputs. In that case, your response must be a list, whose elements must, individually, match the schema \" ;

    let task_prompt = \"TASK: \" + \"($prompt)\" ;

    let output_schema_prompt = \"SCHEMA: \" + \($output_schema | to json\);
    let input_prompt =  \"INPUT: \"  + \($input | to json \)  ;

    let prompt = [$base_prompt, $task_prompt, $output_schema_prompt, $input_prompt] | str join \"\\n---\\n\" ;

    aichat $prompt | from json
}
    "
}
