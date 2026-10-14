use std/log;
use type_utils/ * ;
use cond_utils/ *;
use cmp_utils/ * ;
use file/ ;
use kv_utils/ * ;

export def fetch_contents [
    url: string,
    --depth: int = 3
] {

    ( spider
        --url $url
        --depth $depth
        --stealth
        --verbose
        # --full-resources
        scrape
            --output-html
    )
}
# export def fetch_single_file [url: string] {
#     temp
#     if ($dest_path | path exists) {
#         rm --recursive $dest_path --verbose;
#     }

#     spider --url $url --depth 3 --stealth --verbose download --target-destination $dest_path
# }


export def parse_contents [path] {
    use kv_utils *;
    plugin use query;

    cd $path;
    glob **/*.html |
    par-each {|file_path|

        let path = ( $file_path
            | path relative-to (pwd)
            | str replace --regex "\\.html$" ""
        );

        let content = open $file_path | parse_single_file;
        return {
            path: $path,
            content: $content,
        }
    }
}

export def parse_single_file [] {
    ( $in
    | query web --query "article p"
    | flatten
    | str join "\n"
    )
}
