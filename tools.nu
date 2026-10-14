# use std/dirs ;
# use std/log;
use type_utils/ * ;
use cond_utils/ *;
use cmp_utils/ * ;
# use file/ ;
# use kv_utils/ * ;

export def "pdf to text" [] : [
    path -> list<table>
] {
    let file = $in | path expand;
    let out_dir = mktemp -d;
    let file_name = $file | path basename |  split row "." | first;

    (surya_ocr
        --keep_server
        --images
        --output_dir $out_dir
        $file
    )

    # (chandra
    #     --method hf
    #     $file $out_dir
    # );

    let content = (
        open ($out_dir | path join $file_name "results.json")
        | surya data parse
    );


    $content | to json | log info $in

    $content
}


export def "pdfs to texts" [path?: path, --start_server = true] {
    use kv_utils/ *;
    use std/dirs;
    log set-level 10;


    let path =  $in | default ($path) |  default (pwd);


    log info $"parsing the fucking files at ($path)"

    cd $path;
    mkdir ".texts";

    let files_paths =  (
        | ls **/*.pdf
        | get name
        |  tee {each  {
            log info $"found file ($in)"
        }}
    );


    log info $"( $path )"

    # log info "starting llama server";

    $env.SURYA_INFERENCE_URL = "http://localhost:8080"

    if $start_server {
        let server_job = job spawn {server start }
    }

    # let server_job = job spawn { (llama-server
    #     -hf datalab-to/surya-ocr-2
    #     --hf-file model.safetensors
    #     --ctx-size 4096
    #     --batch-size 256
    #     --threads 4
    #     --port 8080
    # ) };
    # sleep 2.0sec;
    let res = (
        $files_paths
        | each { |p|
            log info $"working on ($p)";
            let cache_path = ".texts" | path join $"( $p ).json"   ;
            let content = if ( $cache_path | path exists | neg ) {
                log info "cache not found. calculating";


                let content = $p |  pdf to text ;

                let cache_path_parent = $cache_path | path dirname;
                if ( $cache_path_parent | path exists | neg) {  mkdir $cache_path_parent }
                $content | to json | save $cache_path -f;

                $content
            } else {
                log info "reusing cache";
                open $cache_path
            };



            let cell_path = $p | dirstruct file_path_to_cell_path ;

            log info $"collected data from ($p)";

            {key: $cell_path, value:  $content}
        }
        | from kv
    );
    $res
}











# export def get_paths [path: path] : [nothing -> table<src_path: path, dest_path: path>] {
#     let paths = ls $"($path)"
#         | get name
#         | wrap src_path
#         | insert dest_path  {
#             get src_path
#             | path relative-to "data/src"
#             | each {|p|
#                 "data/out" | path join $p
#                 | path parse
#                 | update extension ""
#                 | path join
#                 | path expand
#                 | tee { mkdir $in }
#             }
#         }
#     mkdir $"data/out/($path)";

#     $paths
# }





export def --wrapped "ansi link" [--type: string, ...rest] {
    ( if  $type != null {
        let path = $in;
        let url = $"($type)://($in)"
        $url | %ansi link --text $path ...$rest
    } else {
        $in | %ansi link ...$rest
    } )
}
