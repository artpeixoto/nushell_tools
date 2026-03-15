export def do_if [ cond, mapper]   {
    let input = $in ; 
    let satisfies_cond = ($input | do $cond);

    if ( $satisfies_cond ) {
        let result = ( $input | do $mapper ) ; 
        return ( $result )
    } else {
        return ( $input )
    }
} 

export def each_where [cond, map]   {
    $in | each { do_if $cond $map } 
}
