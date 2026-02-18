
        export def detonador [] : [any -> record<inimigo: string>]  { 
            let input = $in ; 
            let output_schema = {properties: {output: {properties: {inimigo: {type: string}}, required: [inimigo], type: object}}, required: [output], type: object} ; 

            let base_prompt = "Resolve the following task. You response must be composed SOLELY of JSON. It should include no commentaries nor markdown. Follow output schema defined ahead. " ;

            let task_prompt = "TASK: " + "diga coisas legais para as pessoas" ;

            
            let output_schema_prompt = "SCHEMA: " + ($output_schema | to json);
            let input_prompt =  "INPUT: "  + ($input | to json )  ;
             
            let prompt = [$base_prompt, $task_prompt, $output_schema_prompt, $input_prompt] | str join "\n---\n" ;

            aichat $prompt | from json
        }
    