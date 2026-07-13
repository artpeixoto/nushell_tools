use ../cmp_utils/ * ;
export def "typeof" [ input? ] : [
    any -> string
] {
    let pipe_in = $in ;

    $input
    | default $pipe_in
    | describe
    | split row "<"
    | first
}

export def "typeof --full" [input?] : [ any -> string ] {
    let pipe_in = $in ;
    $input | default $pipe_in | describe
}

# this is true if the value can be accessed through string cellpaths
export def "is field_container" [] : [any -> bool] {
    $in | typeof | $in in [table record]
}

export def "is element_container" [] : [any -> bool] {
    $in | typeof | $in in [table list]
}

# export def "is container" [] : [any -> bool] {
#     $in | typeof | $in in [table record list]
# }

export def "is iterable" [] : [] {
    $in | typeof | $in in [list table range]
}

export def "is string" [] : [] {
    $in | typeof | eq "string"
} 

# this is true if the type cant be accessed through cellpaths
# inverse of" i"s container
export def "is atomic" [] : [any -> bool] {
    $in | typeof | $in not-in [table record list]
}

export def "is record" [] : [any -> bool] {
    $in | typeof |  eq record
}

export def "is table" [] : [any -> bool] {
    $in | typeof |  eq table
}

export def "is list" [] : [any -> bool] {
    $in | typeof |  eq list
}

export def "is null" [] : [any -> bool] {
    $in | eq null
}

export def "is alternative" [] : [any -> bool] {
    $in | typeof | eq "oneof"
}

export def "is primitive" [] : [] {
    $in | typeof | $in not-in [oneof closure list record table]
}
