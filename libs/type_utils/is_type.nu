export def "type_of" [input: any] : [nothing -> string] {
    $in | describe --detailed | $in.type 
}
export def "is_record" [] : [any -> bool] {
    $in | describe --detailed | $in.type == "record"
}  


export def "is_list" [] : [any -> bool] {
    $in | describe --detailed | $in.type == "list"
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
