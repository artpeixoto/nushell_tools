
export def main [] : [list -> record<input: string, normalized: string>]  { 
    let input = $in ; 
    let output_schema = {properties: {output: {properties: {input: {type: string}, normalized: {type: string}}, required: [input, normalized], type: object}}, required: [output], type: object} ; 

    let base_prompt = "Resolve the following task. You response must be composed SOLELY of JSON. It should include no commentaries nor markdown. Follow output schema defined ahead. " ;

    let task_prompt = "TASK: " + "os números de telefone abaixo estão despadronizados. Alguns tem caracteres nao desejados, outros estão incompletos. Preciso que você me ajude com isso, por favor. Eu preciso que você os reescreva da forma correta. Ela é com código de país, código de estado e resto do número. Apenas com caracteres numéricos. Se não tiver codigo de país, assuma que é o brasil, cujo código é 55. Se não tiver código de estado, assuma goiás, cujo código é 62. O corpo do número deve 9 digitos, mas as vezes o 9 a esquerda não é adicionado na entrada. Por exemplo, o telefone 6281533392 tem 10 digitos. Isso porque ele foi informado o codigo do estado. Nessas situações, voce deve adicionar esse digito também. Então, o '6281533392' deve virar '5562981533392'. ESe o número em si tiver 8 digitos, complete com o 9 no começo. 
Exemplos: 
-'8253-3294' => '5562982533294'
'(62) 9 8159 3296' => '5562981593296'" ;
    
    
    let output_schema_prompt = "SCHEMA: " + ($output_schema | to json);
    let input_prompt =  "INPUT: "  + ($input | to json )  ;
        
    let prompt = [$base_prompt, $task_prompt, $output_schema_prompt, $input_prompt] | str join "\n---\n" ;

    aichat $prompt | from json 
}
