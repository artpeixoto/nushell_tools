use ../type_check.nu * 

export def "rename --deep" [renamer: closure] : [any -> any] {
    mut renamed = $in | rename --block $renamer  ;
    let cols = $renamed | columns ; 
    
    for col in $cols { 
        $renamed = $renamed | update $col {
            let field = $in ; 
            if ($field | is_field_container) {
                $field | rename --deep $renamer
            } else {
                $field
            }
        }
    }

    $renamed
} 

