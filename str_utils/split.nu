export def "str split-at" [index: int] : [string -> list<string>] {
    let lhs = $in | str substring ..($index - 1) ; 
    let rhs = $in | str substring ($index).. ; 

    [$lhs, $rhs]
}