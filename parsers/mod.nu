# export use from_srt.nu  * ;
# export

export def "m exact" [str: string] {
    let input = $in;

    if ($input.rest | str starts-with $str) {
        let new_rest = $input.rest | str substring ($str | str length)..;
        let value = $str;
        return [ {
            value: $value,
            next: {
                rest: $new_rest,
                ctx: $input.ctx
            }
        }]
    } else {
        return []
    }
}
export def "m map_val" [parser: closure, mapper: closure] {
    let input = $in;

    $input
    | do $parser
    | each {update value $mapper}
}

export def "m seq" [...subparsers: closure] {
    let input = $in;
    match ($subparsers | length) {
        0 => { error make "no subparsers" }
        1 => {
            let parser = $subparsers.0;

            $input
            | do $parser
            | each { update value {[$in]} }
        }
        _ => {
            let first = $subparsers.0;
            let rest_parser = {m seq ...( $subparsers | skip 1) }
            $input
            | do $first
            | each {|res|
                $res.next
                | do $rest_parser
                | each { update value {prepend [$res.value]} }
            }
            | flatten
        }
    }
}

export def "m named_seq" [ subparsers: record] {
    use kv_utils/ * ;
    let input = $in;

    let subparsers =  (
        $subparsers
        | items {|k, v| {
            $in
            | m map_val $v {
                $in | wrap value | insert key $k
            }
        } }
    )
    $input
    | do { $in | m map_val {m seq ...$subparsers} {from kv} }
}


export def "m oneof" [...subparsers: closure] {
    let input = $in;
    for subparser in $subparsers {
        let res = $input | do $subparser;
        if ($res | is-not-empty) {return $res}
    }
}


export def "m repeat-lazy" [subparser: closure, range: record] {
    let max = $range | get end --optional ;
    let min = $range | get start --optional  | default {0};

    mut rep_count = 0
    mut results = [];
    mut current = $in;
    (
        generate
        {|cur|
            let rest = $cur | do $subparser | first
            if ($rest == null) { return {}}
            {
                out: ($rest | get value --optional)
                next: ($rest | get next)
            }
        }
        $current
    )
}
