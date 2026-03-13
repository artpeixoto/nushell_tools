export def "str escape" [] : [string -> string] {
    $in | to json #lmao
}

export def "str unescape" [] : [string -> string] {
    $in | from json
}

