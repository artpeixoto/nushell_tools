use openapi_utils ensure_operation_ids;
use std/log ;
use kvp_utils * ;
use cmp_utils * ;
use std-rfc/iter recurse ;
use type_utils * ;
export def main [] {
    let data = $in;

    let data = $data | ensure_operation_ids ;

    mut new_data = $data ;
    
    let to_change = (
        $data | 
        recurse | 
        where {|el|  match $el.item { {format: $item} => true, _ => false }} | 
        where ($it.item.format =~ "int" or $it.item.format =~ "double") and $it.item not-has "type" 
    )

    for field in $to_change {
        mut item = $field.item; 
        let format = $item.format;

        $item.type = if ($format =~ "double") {
            "number"
        } else {
            "integer"
        }

        if ($item has pattern) {
            $item = $item | reject pattern 
        }

        $new_data = $new_data | update $field.path $item
    }

    let data = $new_data;


    let data = (
        $data | recurse | 
        where {|el| $el.item | is_record } | 
        where {|el| $el.item |  columns | $in has content } | 
        where {|el| $el.item.content | columns | length | gt 1 } |
        each { |el| 
            if ( $el.item.content not-has "application/json" ) { return null; }
            mut new_item = $el.item;
            $new_item.content = $new_item.content | select "application/json"

            return {path: $el.path, item: $new_item}
        }
        | where {neq null}
        | reduce --fold $data  {|it, acc| 
            log info $"updating ($it.path) with value ( $it.item )"
            $acc | update ( $it.path ) ($it.item)  
        }
    )

    $data
}