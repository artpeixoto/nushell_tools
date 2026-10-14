use ./conversion.nu * ;

export def "get --from_kv" [
    key: any,
    --key_path   (-k) : oneof<string, oneof<cell-path, int>> = key, 
    --value_path (-v) : oneof<string, oneof<cell-path, int>> = value
] : [table -> any] { 
    $in | where { get $key_path | $in ==  $key } | first | get $value_path 
    # $in | from kv -k $key_path -v $value_path | get 
}

export def "select --from_kv" [
    --key_path   (-k) : oneof<string, oneof<cell-path, int>> = key, 
    --value_path (-v) : oneof<string, oneof<cell-path, int>> = value,
    ...selectors
] : [
    table -> table
] { 
    $in | from kv -k $key_path -v $value_path | select ...$selectors | into kv -k $key_path -v $value_path
}

export def "update --from_kv" [
    field: any,
    replacer: any,
    --key_path   (-k) : oneof<string, oneof<cell-path, int>> = key, 
    --value_path (-v) : oneof<string, oneof<cell-path, int>> = value,
    --form = both # can be either key, value or both
] { 

}


# export def "update --as_kv" [] {

# }



