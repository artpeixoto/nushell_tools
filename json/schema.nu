export def infer [] : [any -> any] {
    $in | to json |  genson-cli | from json
}
export def "infer --raw" [] : [any -> any] {
    $in  |  genson-cli | from json
}


export def validate [
    schema: record
] : [
    any -> any
] {
    let input = $in ;
    let schema_path  = $schema | to json | save_temp ;

    $input |
    to json |
    jsonschema-cli $schema_path --output hierarchical --errors-only |
    from json
}


def save_temp [] : [oneof<string, binary> -> path] {
    
    let path = ignore | mktemp -t ;
    save --raw -f $path ;
    $path
}
