use ./kv_utils/ * ;

export def "from db" []: [string -> table] { 
    let input = $in ; 
    let lines = $input | lines ;
    let start = 0 ;
    let header_line = $lines | first ;

    let width =  $header_line | str length ;
    let split_cols = ($header_line | split chars | enumerate | where $it.item == '|' | get index) ;

    let last_marker = $split_cols | last;
    let first_marker = $split_cols | first ; 
    
    let windows = (
        ($split_cols | drop 1) | zip ($split_cols | skip 1) | 
        each  {  ( $in.0 + 1 )..( $in.1 - 1  ) }
    );

    let windows = [..($first_marker - 1), ...$windows, ($last_marker + 1)..];

    let split_cells = {$in | let line;  $windows | each {|w| $line | str substring $w | str trim } }

    let headers = $header_line | do $split_cells ;

    let value_lines  = $lines  | skip 2 | drop 1;

    $value_lines | par-each --keep-order {$in | do $split_cells | each {detect type} | let values; $headers | zip $values | from kvs --by-order }
    
} 
