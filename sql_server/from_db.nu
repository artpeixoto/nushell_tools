use ./kv_utils/ * ;
use std/log;
use ./type_utils/ * ; 

export def "from db" []: [] { 
    let start = 0 ;
    let header_line = $in | first ;

    let headers = $header_line | parse_db_headers ;

    $in | skip 2 | drop 1 | each { parse_db_row $headers }  
} 

export def parse_db_row [headers: table<name: string, range: range>] : [string -> record] { 
    mut row     = {};
    let row_str = $in ;

    for $header in $headers {
        let value = $row_str | str substring ( $header.range ) | str trim ;
        $row = $row | upsert $header.name $value ;
    }

    $row 
}

export def parse_db_headers [--sep: string = '|'] : [string -> table<name: string, range: range>] {
    let header_line = $in ;
    let width =  $header_line | str length ;
    let split_cols = ($header_line | split chars | enumerate | where $it.item == $sep | get index) ;

    let last_marker = $split_cols | last;
    let first_marker = $split_cols | first ; 
    
    let windows = (
        ($split_cols | drop 1) | zip ($split_cols | skip 1) | 
        each  {  ( $in.0 + 1 )..( $in.1 - 1  ) }
    );

    let windows = [..($first_marker - 1), ...$windows, ($last_marker + 1)..];

    let split_cells = {
        $in | let line;  
        $windows | each {|w| $line | str substring $w | str trim }
    }

    let headers = $header_line | do $split_cells | zip $windows | each {|header| {name: $header.0, range: $header.1}} ;
    

    return $headers;
}