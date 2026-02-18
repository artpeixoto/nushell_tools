
export def infer [] : [any -> any] {
    $in | to json |  genson-cli | from json | reject "$schema"
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
    let path = mktemp -t ;
    $in | save --raw -f $path ; 

    $path 
}