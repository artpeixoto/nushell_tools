use ../cmp_utils/ * ;
export def "typeof" [ input? ] : [
    any -> string
] {
    let pipe_in = $in ; 
    $input | default $pipe_in | describe | split words | first
}

export def "typeof --full" [input?] : [ any -> string ] {
    let pipe_in = $in ; 
    $input | default $pipe_in | describe  
}

# this is true if the value can be accessed through string cellpaths
export def is_field_container [] : [any -> bool] { 
    $in | typeof | $in in [table record]
}

export def is_element_container [] : [any -> bool] {
    $in | typeof | $in in [table list]
}

# export def is_container [] : [any -> bool] {
#     $in | typeof | $in in [table record list]
# }

export def is_iterable [] : [] {
    $in | typeof | $in in [list table range]
}

# this is true if the type cant be accessed through cellpaths
# inverse of is_container
export def is_atomic [] : [any -> bool] {
    $in | typeof | $in not-in [table record list]
}

export def is_record [] : [any -> bool] {
    $in | typeof |  eq record
}

export def is_table [] : [any -> bool] {
    $in | typeof |  eq table
}

export def is_list [] : [any -> bool] {
    $in | typeof |  eq list
}

export def is_null [] : [any -> bool] {
    $in | eq null
}

export def is_alternative [] : [any -> bool] {
    $in | typeof | eq "oneof"
}

export def is_primitive [] : [] {
    $in | typeof | $in not-in [oneof closure list record table]
}
