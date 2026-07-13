export def "do if" [ cond: closure , mapper: closure ] {
    let input = $in ;
    let satisfies_cond = ($input | do $cond);

    if ( $satisfies_cond ) {
        let result = ( $input | do $mapper ) ;
        return ( $result )
    } else {
        return ( $input )
    }
}

export def "each where" [cond, map]   {
    $in | each { do if $cond $map }
}
