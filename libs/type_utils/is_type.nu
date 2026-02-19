export def "is_record" [] : [any -> bool] {
    $in | describe --detailed | $in.type == "record"
}  
export def "is_list" [] : [any -> bool] {
    $in | describe --detailed | $in.type == "list"
} 

export def "is_nothing" [] : [any -> bool] {
    $in == null
}
