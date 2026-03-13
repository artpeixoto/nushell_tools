use ../cmp_utils/ *;

export def "type" [] : [any -> string] {
    $in | describe 
}

export def "type --major" [] : [any -> string] {
    $in | describe | split words | first
}

export def "is record" [] : [any -> bool] {
    $in | type --major | eq "record"
}  

export def "is table" [] : [any -> bool] {
    $in | describe | str starts-with 'table'
}

export def "is list" [] : [any -> bool] {
    $in | describe | str starts-with 'list'
} 

export def "is iterable" [] : [any -> bool] {
    $in | type --major | $in in [table list]
}

export def "is null" [] : [any -> bool] {
    $in == null
}

export def "is alternative" [] : [any -> bool] {
    $in | describe --detailed | $in.type == "null"
}

export def "is value" [] : [any -> bool] {
    $in | describe --detailed | $in.type not-in [oneof closure list record table]
} 

# basically, returns if the value is of type table or record;
export def "is container" [] : [any -> bool] {
    $in | type --major | $in in [table record] 
}