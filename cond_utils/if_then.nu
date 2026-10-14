use ../type_utils/type_check.nu  * ;
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

export def "drop if" [cond: oneof<bool, closure>] : [any -> oneof<any, nothing>]  {
    let should_drop =  match  ( typeof $cond ) {
        "bool" => { $cond },
        "closure" => { $in | do $cond }
    };

    if $should_drop {
        null
    } else {
        $in
    }
}

export def "keep if" [cond: oneof<bool, closure>] : [any -> oneof<any, nothing>]  {
    let should_keep =  match  ( typeof $cond ) {
        "bool" => { $cond },
        "closure" => { $in | do $cond }
    };

    if $should_keep {
        $in
    } else {
        null
    }
}
