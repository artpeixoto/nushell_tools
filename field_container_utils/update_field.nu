 export def "update field" [
     path: oneof<cell-path, oneof<string , int>>,
     updater: oneof<closure,  record<key: oneof<cell-path, oneof<string, int>>, value:  any>>
     --optional
] {
    use ../type_utils/ * ;

    let updater = match ( $updater | typeof ) {
        closure => {
            $updater
        },
        record  => {
            let a =  {|| return $updater  }
            $a
        }
    };
    let input = $in;

    let new_field = ( $input | get $path | each $updater );

    if $new_field != null {
        ( $input
        | update $path $new_field.value
        | rename --column ({} | insert $path $new_field.key)
        )
    } else {
        $input
    }
}
