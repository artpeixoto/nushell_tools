export def "str escape" [] : [string -> string] {
    $in | to json 
}

export def "str unescape" [] : [string -> string] {
    $in | from json
}