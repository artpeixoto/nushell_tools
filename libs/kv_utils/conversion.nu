use ../type_utils/type_check.nu *;

export def "into kv" [] : [any -> table<key: string, value: any>] {
    let input = $in ; 
    $input | columns | wrap key | insert value {|col| $input | get $col.key} 
}

# export def "into kv --deep" [] : [any -> table<key: string, value: any>] {
#     let input = $in ; 
#     $input | columns | wrap key | insert value {|col| $input | get $col.key} 
# }


export def "from kv" [
    --key_path (-k)   : oneof<string, oneof<cell-path, int>>, 
    --value_path (-v) : oneof<string, oneof<cell-path, int>>
] : [
    table<key: string, value: any> -> record,
    table<path: string, item: any> -> record,
    table       -> record,
    list<any>   -> record
] {
    let input = $in ; 

    let get_default_paths = {
        if ($input | is_table) {
            let cols = $input | columns ;
            if ("key" in $cols and "value" in $cols) {
                return {key_path: "key", value_path: "value"}
            } else if ("path" in $cols and "item" in $cols)  {
                return {key_path: "path", value_path: "item"}
            } else {
                return {key_path: $cols.0, value_path: $cols.1}
            }
        } else if ($input | is_list) {
            return {key_path: 0, value_path: 1}
        } else {
            let input_type = $input | typeof --full ; 
            let input_metadata =  metadata $input
            error make {
                msg: $"i dont know how to deal with type ($input_type)"
                labels: [{
                    label: "in",
                    span: $input_metadata.span
                }] 
            }
        }
    };
    let paths = if (not ($key_path  == null or $value_path == null)) {
        let default_paths = do $get_default_paths ;
        $default_paths | merge ({key_path: $key_path, value_path: $value_path} | compact) 
    } else {
        {key_path: $key_path, value_path: $value_path}
    }
     
    mut res = {}
    
    for item in $in {
        $res = $res | merge ( ($item | get $paths.value_path) | wrap ($item | get $paths.key_path) ) ;
    }

    $res 
} 


export def "from kv --list" [] : [
    list<list> -> record
] {
    mut res = {}
    for item in $in {
        $res = $res | merge ($item.1 | wrap $item.0) ;
    }

    $res 
}