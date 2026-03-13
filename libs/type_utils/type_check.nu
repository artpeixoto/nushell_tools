use ../cmp_utils/ *;

export def "type" [] : [any -> string] {
    $in | describe 
}

export def "type --major" [] : [any -> string] {
    $in | describe | split words | first
}

export def "is_record" [] : [any -> bool] {
    $in | type --major | eq "record"
}  

export def "is_table" [] : [any -> bool] {
    $in | describe | str starts-with 'table'
}

export def "is_list" [] : [any -> bool] {
    $in | describe | str starts-with 'list'
} 

export def "is_iterable" [] : [any -> bool] {
    $in | type --major | $in in [table list]
}

export def "is_null" [] : [any -> bool] {
    $in == null
}

export def "is_alternative" [] : [any -> bool] {
    $in | describe --detailed | $in.type == "null"
}

export def "is_value" [] : [any -> bool] {
    $in | describe --detailed | $in.type not-in [oneof closure list record table]
} 

# basically, returns if the value is of type table or record;
export def "is_container" [] : [any -> bool] {
    $in | type --major | $in in [table record] 
}