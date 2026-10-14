use ../kv_utils/ * ; 
use ../str_utils/ * ;
export def --wrapped main [...rest] {
    let inner = ^lsof -F ...$rest | lines | each {separate_field_name_and_value};
    let first_field_name = ( $inner | first | get key); 
    let records = $inner | split list {get key | $in == $first_field_name} | each { from kv }
    $records
}

def separate_field_name_and_value [] {
    let parts = $in | str split-at 1  ;
    {key: $parts.0, value: $parts.1}
}
