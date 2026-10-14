use html.nu ;
use media/ * ;
use std/dirs ;
use std/log;
use type_utils/ * ;
use cond_utils/ *;
use cmp_utils/ * ;
use file/ ;
use kv_utils/ * ;
use tools.nu * ;
use dirstruct.nu * ;
use pdf.nu ;



export def "server health" [] {

}

export def "server stop" [] {

}

export def "hf download model" [model_url: string] : [nothing -> string] {
  hf download $model_url --json | from json | get path
}
export def "server start" [] {

    let model_dir_path = hf download model "datalab-to/surya-ocr-2-gguf"
    let model_path = $model_dir_path | path join surya-2.gguf  | realpath $in
    let mm_proj_path = $model_dir_path | path join surya-2-mmproj.gguf  | realpath $in

    (
        llama-server
            -m $model_path
            --mmproj $mm_proj_path
            --alias datalab-to/surya-ocr-2
            -lv 4
            --host 127.0.0.1 --port 8080
            --load-mode mlock
            --gpu-layers 99
	    --threads 4
            --parallel 2 --ctx-size (16384 * 2)
            --jinja
    )
}

export def "infer blocks" [
    --remaining_depth = 1
] : [
    record<
        content: binary,
        metadata: record<size: record, type: string>
    > -> list<record<>>
] {
    let image = $in;

    let surya_output = (
        $image
        | image save_temp
        | wrap_cmd_with_folder "surya_layout" --images
    );


    let p = $surya_output.results;

    # log debug $"inference result: \n( $p | table -e) ";


    $p.bboxes.0
    | each {|block|
        let type = ( $block.raw_label | parse block label);
        let bbox = (
            $block.bbox
            | parse bbox
            | {l: ($in.l - 10) , r: ( $in.r + 5 ), b: ( $in.b + 5 ) t: ($in.t - 5)}
            | rect intersect {l:  0, t: 0, r: $image.metadata.size.w, b: $image.metadata.size.h}
        );

        mut res = {
            type: $type,
            bbox: $bbox,
            content_size_est: $block.count
            # render: $render,
        };

        log info $"found ($type) block"
        if $type.data == composite and $remaining_depth >= 0 {
            let block_image = $image | image op crop $bbox;
            let children = $block_image | infer blocks --remaining_depth ($remaining_depth - 1)
            $res.children = $children | block offset bboxes {x: $bbox.l, y: $bbox.t}
        }


        $res
    }
}

export def "block scale bboxes"  [scale: float] : [table -> table] {
    $in
    | each {|entry|
        mut entry = $entry;
        $entry.bbox = $entry.bbox | into kv | update value {$in * $scale} | from kv;

        if ($entry has children) {
            $entry.children  = ( $entry.children  | block scale bboxes $scale ) ;
        }
        $entry
    }
}


export def "block offset bboxes" [pos: record<x, y>] : [table -> table] {
    $in
    | each {|entry|
        mut entry = $entry;
        $entry.bbox = $entry.bbox | rect move $pos;

        if ($entry has children) {
            $entry.children  = ( $entry.children  | block offset bboxes $pos ) ;
        }
    }
}

export def infer [] : record -> table {
    ( $in
    | image save_temp
    | wrap_cmd_with_folder "surya_ocr"
    | tee {to json | log info $in}
    | get results.0.blocks
    | each {|block|
        let type = ( $block.raw_label | parse block label);
        let bbox = ( $block.bbox | parse bbox);

        mut res = {
            type: $type.data,
            semantic: $type.semantic,
            bbox: $bbox,
            content: $block.html
            # render: $render,
        };
        $res
    })
}

export def "infer text"  [] : record -> string {
    ( $in
    | image save_temp
    | wrap_cmd_with_folder "surya_ocr"
    | tee {to json | log info $in}
    | get results.0.blocks.html
    )
}

export def "infer table" [] : record -> string {
    let content = (
        $in
        | image save_temp
        | ( wrap_cmd_with_folder "surya_table" --mode full )
        | inspect
        | get results.0.html --optional | default "<table><tbody></tbody></table>"
        | tee {to json | log info $"table content: ($in)"}
    );

    $content
}

def --env load_surya_env [] {
    $env.SURYA_INFERENCE_BACKEND = "llamacpp";
    $env.SURYA_INFERENCE_URL = "http://localhost:8080";
}


export def --wrapped "wrap_cmd_with_folder" [cmd: any, ...parms ] : [path -> any]  {
    load_surya_env;
    let input = $in;
    let cmd = match ( $cmd | typeof ) {
        string =>  {
            {|out| ^$cmd ...$parms  --keep_server --output_dir $out $in }
        }
        closure => { $cmd }
    }


    let out_file_data =  (
        with_output_dir {|out| $input | do $cmd $out }
        | values
        | first
    ) ;

    let results =  (
        $out_file_data
        | get results.content
        | from json
        | values | first
    );

    let other_files = $out_file_data | reject results ;

    {
        results: $results,
        rest: $other_files
    }
}

export def "parse bbox" [] : [list<number> -> record<l: number, r: number, t: number, b: number>] {
    $in
    | {
        l: ( $in.0 ),
        r: ( $in.2 ),
        t: ( $in.1 ),
        b: ( $in.3 )
    }
}


export def "data parse" [--clean = true] : [ record -> list< table > ] {
    use kv_utils/ * ;
    $in
    | into kv
    | get 0.value
    | each {
        get blocks
        | sort-by {get reading_order}
        | reject reading_order
        | each { |b|
            let b = (
                $b
                | update bbox  { parse bbox }
                | update kind { ($in.raw_label | str snake-case ) }
                | rename --column {html: content}
            );

            if ( $clean ) {
                $b | select bbox kind content
            } else {
                $b
            }
        }
    }
}

export def "parse block label" []: [string -> record<semantic: string, data: string>] {
    let label = $in;

    let sem_type = $label | str snake-case;

    # "Caption"
    # "Footnote"
    # "Equation-Block"
    # "List-Group"
    # "Page-Header"
    # "Page-Footer"
    # "Image"
    # "Section-Header"
    # "Table"
    # "Text"
    # "Complex-Block"
    # "Code-Block"
    # "Form"
    # "Table-Of-Contents"
    # "Figure"
    # "Chemical-Block"
    # "Diagram"
    # "Bibliography"
    # "Blank-Page"

    let data_to_semantic = {
        empty    : [ blank_page]
        composite: [   equation_block, ],
        image    : [ figure, image, diagram, chemical_block, equation,  complex_block,],
        list     : [ list_group]
        table    : [ table, form]
        text     : [ text, section_header,  caption, footnote, code, bibliography, table-of-contents, page_header, page_footer,  ]
    };

    let semantic_to_data = {
        blank_page: empty,
        complex_block : image,
        equation_block: composite,
        page_header   : text,
        page_footer   : text,
        figure: image,
        image: image,
        diagram: image,
        chemical_block: image,
        equation: image,
        list_group: list,
        table: table,
        form: text,
        text: text,
        section_header: text,
        caption: text,
        footnote: text,
        code: text,
        bibliography: text,
        table-of-contents: text
    };

    let data_type = $semantic_to_data | get  $sem_type;

    {data: $data_type, semantic: $sem_type}
}
