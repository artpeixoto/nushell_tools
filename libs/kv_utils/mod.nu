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

export def "into kvs" [] : [any -> table<key: string, value: any>] {
    let input = $in ; 

    $input | columns | wrap key | insert value {|col| $input | get $col.key} 
}

export def "from kvs" [] : [table<key: string, value: any> -> record] {
    mut res = {}

    for item in $in {
        $res = $res | merge ($item.value | wrap $item.key) ;
    }

    $res 
} 



export def "from kvs --by-order" [] : [list<list> -> record] {
    mut res = {}

    for item in $in {
        $res = $res | merge ($item.1 | wrap $item.0) ;
    }

    $res 
}