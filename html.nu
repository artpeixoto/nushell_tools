use cond_utils/ * ;
use cmp_utils/ * ;
use kv_utils/ * ;

export def "parse table" [] : oneof<string, binary> -> table {
    let content = $in ;
    let rows = $content | query  "tr"  ;
    let header =  $rows | each { query  "th"  --text } | enumerate | where {$in.item | is-not-empty}  | first;

    let rows = if ( $header | is-not-empty ) {
        $rows | reject $header.index
    } else {
        $rows
    };


    let data    = $rows | each {query "td" --text};

    if ( $header | is-not-empty) {
        $data
        | each {|row| $header.item | zip $row | from kv --list}
    } else {
        $data
    }
}

export def simplify_xml [] {
    let key = $in.tag;
    let values = (
        $in.content
        | each {|child|
            if $child.tag == null {
                $child.content
            } else {
                $child |  simplify_xml
            }
        }
    );
    # let values = if ( $values | length | eq 1 ) {
    #     $values.0
    # } else {
    #     $values
    # }

    {} | insert $key $values
}


export def --wrapped "query" [query: string, --text, ...rest] {
    $in
    | scrape --expression $query ...$rest
    | $"<wrapper>($in)</wrapper>" # this is not a good solution but i ain't got time
    | from xml
    | get content
    | each {|el|
        if ($el.tag | is-empty )  {
            $el.content
        } else {
            $el | to xml
        }
    }
    | do if {$text} { $in  |  each {
        $in | scrape  --text
    } }
}
