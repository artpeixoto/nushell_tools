use ./type_check.nu * ; 
use ../kv_utils/  * ;

export def "rename --deep" [renamer: closure] : [any -> any] {
    mut renamed = $in | rename --block $renamer  
    let cols = $renamed | columns ; 

    for col in $cols { 
        $renamed = $renamed | update $col {
            let field = $in ; 
            if ($field | is_container) {
                $field | rename --deep $renamer
            } else {
                $field
            }
        }
    }
    $renamed
} 

