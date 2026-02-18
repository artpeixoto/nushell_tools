use aifunc;
export def main [] : [string -> table<topic: string, content: string>] {
    let prompt = "o texto que eu vou te passar fala de muitas coisas. Eu gostaria que você separasse ele de acordo com o assunto. Pra cada bloco, me informa a linha de inicio, e a linha de fim, o assunto em uma frase pequena. Para te ajudar, cada linha do texto foi enumerada.";
    let schema = {properties: {pieces: {type: array, items: {properties: {assunto: {type: string}, inicio: {type: integer}, fim: {type: integer}}, required: [assunto, fim, inicio], type: object}}}, required: [pieces], type: object};

    let text_input = $in;
    let lines_text_input = $text_input | lines;
    let ai_text_input = $text_input | lines | each {|row| $"($row.index): ($row.item)"} | str join "\n";
    
    let resp = aifunc $prompt $schema  | get pieces ; 

    $resp | each {|bloco| 
        let str_bloco = $text_input | lines | slice $bloco.inicio..$bloco.fim | str join "\n"; 
        return {topic: $bloco.assunto, content: $str_bloco}
    }
}