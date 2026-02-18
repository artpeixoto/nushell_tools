export def "into kvps" [] : [any -> table<key: string, value: any>] {
    let input = $in ; 

    $input | columns | wrap key | insert value {|col| $input | get $col.key} 
}
export def "from kvps" [] : [table<key: string, value: any> -> record] {
    mut res = {}

    for item in $in {
        $res = $res | merge ($item.value | wrap $item.key) ;
    }

    $res 
} 