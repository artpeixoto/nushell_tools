use std/log;
use type_utils/ * ;
use cond_utils/ *;
use cmp_utils/ * ;
use file/ ;
use kv_utils/ * ;
use tools.nu * ;

export def "file_path_to_cell_path" [--remove_ext = false] : path -> cell-path  {
    let  path = $in;
    let pieces = if $remove_ext {
        let parts  = $path | path parse;
        [
            ...($parts.parent | path split),
            $parts.stem
        ]
    } else {
        $path | path  split
    };

    $pieces
    | into cell-path
}

export def "read" [dir?: path] : [nothing -> record, path -> record] {
    use kv_utils/ * ;
    let dir = $in | default ($dir) | default  (pwd) | path expand ;

    cd $dir;

    let file_paths =  (
        ls **/*
        | where type != dir
        | get name
        | each {path  expand}
    ) ;

    $file_paths
    | each {|p|
        let key  =  (
            $p
            | path relative-to $dir
            | file_path_to_cell_path --remove_ext true
        );

        log debug $"reading content from ($p | ansi link --type file)";

        let extension = $p  | path parse | get extension? ;
        let content = open $p --raw ;

        {key: $key, value: { type: $extension , content: $content, path: $p }}
    }
    | from kv
}

export def with_output_dir [func: closure, ] {
    let out_dir = mktemp -d;
    log debug $"using temp dir: (  $out_dir | ansi link --type file )";

    do $func $out_dir ;
    cd $out_dir ;

    let content = read ;
    $content
}
