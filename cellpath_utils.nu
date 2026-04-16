export module cellpath { 
    export const zero = $.;
    export def parse [] : [oneof<cell-path, string> -> table] {
        $in | split cell-path 
    }

    export def split [] : [oneof<cell-path, string> -> list<cell-path>] {
        $in | split cell-path | each {[$in] | into cell-path}
    }
     
    export def join [...paths: oneof<cell-path, string>] : [
        nothing -> cell-path, 
        list<oneof<cell-path, string>> ->  cell-path, 
        oneof<cell-path, string> -> cell-path,
    ] {
        let arg_paths = $paths   ;
        let pipe_paths = $in | default [] | [$in] | flatten  ;

        [$arg_paths, $pipe_paths] | 
            inspect | 
            flatten  |  
            each { into cell-path | split cell-path } | 
            flatten | 
            into cell-path  
    }

    export def "from parsed" [] : [table -> cell-path] { 
        into cell-path
    }
}