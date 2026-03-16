use ./aifunc;
use std/log;

export def main [] : [string -> table<topic: string, content: string>] {
    let prompt = "o texto que eu vou te passar fala de muitas coisas. Eu gostaria que você separasse ele de acordo com o assunto. Pra cada bloco, me informa a linha de inicio, e a linha de fim, o assunto em uma frase pequena. Para te ajudar, cada linha do texto foi enumerada.";

    let output_example = {parts: [{start: 0, end: 10, topic: "the essence of the universe"}] };

    let text_input = $in;
    let lines_text_input = $text_input | lines;
    let ai_text_input = $text_input | lines | enumerate | each {|row| $"($row.index): ($row.item)"} | str join "\n";
    

    let resp = $ai_text_input | aifunc  $prompt $output_example ;
    log info $"ai resp is: ( $resp )";

    $resp | get parts | each {|bloco| 
        let str_bloco = (
            $text_input | 
            lines | 
            slice $bloco.start..$bloco.end | 
            str join "\n"
        ); 

        return {topic: $bloco.topic , content: $str_bloco}
    }
}