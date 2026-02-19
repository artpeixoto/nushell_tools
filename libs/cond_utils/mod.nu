
export def do_if [cond: closure, mapper: closure] : [any -> any] {
    let input = $in ; 
    if ($in | do $cond ) {
        $in | do $mapper
    } else {
        $in
    }
} 

export def map_where [cond: closure, map: closure] : [
    any -> any
] {
    $in | each { do_if $cond $map } 
}