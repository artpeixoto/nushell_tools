export def do_if [cond: closure, mapper: closure] : [any -> any] {
    let input = $in ; 
    let satisfies_cond = ($input | do $cond);
    if $satisfies_cond {
        let result = $input | do $mapper ; 
        $result
    } else {
        $input
    }
} 

export def map_where [cond: closure, map: closure] : [ any -> any ] {
    $in | each { do_if $cond $map } 
}