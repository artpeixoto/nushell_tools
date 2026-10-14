use html.nu ;
use media/ * ;
use std/log;
use type_utils/ * ;
use cond_utils/ *;
use cmp_utils/ * ;
use file/ ;
use kv_utils/ * ;
use tools.nu * ;
use surya-ocr.nu;
use glm-ocr.nu;
use pdf.nu ;

const data_collection_resolution = 150;
const block_inference_resolution = 75;

export def run_inference [...files] {
  let resources_path = "resources" |  path expand;
  let files = $files | default -e {ls resources/**/*.pdf | get name} | each {path expand } ;

  mkdir out;
  cd out;

  $files
  | each {|f|
    let src_path = $f;
    let out_local_dir = (
      $f
      | path relative-to $resources_path
      | path parse | update extension {""} | path join
    );
    mkdir $out_local_dir;
    cd $out_local_dir;

    pdf render $src_path
    | enumerate
    | each {|e|
      let index = $e.index;

      let dir = $"page-($index)";

      mkdir $dir;
      cd $dir;

      if (ls | get name | any {$in == "content.html"} ) {
	log info $"skipping page ($index) of file ($src_path)";
      	return;
      } else {
      let page_render = $e.item;
      $page_render | get content | viu - ;
      sleep 0.1sec;


      log info $"infering page ($index) of file ($src_path)";

      let page = $page_render | surya-ocr infer;

      $page.content | str join "\n\n" | save content.html -f;
      $page                           | save result.json -f;
      }
    }
  }
}

export def infer [file: path, --pages: int] {
    $file
    | pdf render --res $block_inference_resolution
    | enumerate
    | where {
        if  ($pages != null) {
            ( $in.index < $pages )
        } else {
            true
        }
    }
    | each {|page|
        $page.item
        | surya-ocr infer blocks
        | each {|block|
            let scale = $data_collection_resolution / $block_inference_resolution;
            let block = [$block] | surya-ocr block scale bboxes $scale | first;
            pdf render --block $file $page.index $block.bbox  --res $data_collection_resolution | image show;
            let content = infer block content $file $page.index $block;
            print $content.content;
            $content
        }
    }
}


export def "infer block content" [file: path, page: int, block: record<type, bbox, content_size_est>] {
    match $block.type.data {
        text => {
            log info $"infering text from block ($block.bbox) page ($page) of ($file)"
            (infer text
                $file
                $page
                $block.bbox
                $block.content_size_est
            )
        },
        table => {
            log info $"working with table block ($block.bbox) page ($page) of ($file)"
            (infer table
                $file
                $page
                $block.bbox
            )
        }
        image => {
            log info $"working with image block at ($block.bbox) page ($page) of ($file)"
            (infer image
                $file
                $page
                $block.bbox
            )
        }
        composite => {
            log info $"working with composite block ($block.bbox) page ($page) of ($file). will infer children"

            $block.children?
            | each { infer block content $file $page $in}
        }

        _ => {
            (infer text
                $file
                $page
                $block.bbox
                $block.content_size_est
            )
        },
    }
}

## BLOCK TYPE
# record<
#     type: record<
#         data: string,
#         semantic: string
#     >,
#     bbox: record<
#         l: float,
#         r: float,
#         t: float,
#         b: float
#     >,
#     content_size_est: int
# >

export def "infer text" [file: path, page: int, bbox: record<l,r,t,b>, content_size: int] {

#    let extraction_res = do {
#        pdf extract text --block $file $page $bbox --res $data_collection_resolution
# };

    let extraction_res = (
      pdf render --block $file $page $bbox --res $data_collection_resolution
      | surya-ocr infer text
      | str join "\n\n"
      | wrap content
    );

    return $extraction_res;

####let extraction_is_enough = do {
####    let extraction_content_size = $extraction_res | split words | length  | into float | $in * 1.33;
####    let rel =  ( $extraction_content_size / ( $content_size | into float) ) ;
####    let is_too_small = $rel < 0.15
####    ( not $is_too_small )
####}

####if $extraction_is_enough {
####    $extraction_res
####} else {
####    log info "text extraction came with too little content. will use ocr";

####    pdf render --block $file $page $bbox --res $data_collection_resolution
####    | surya-ocr infer text
####}
####| str trim
####| split row "\n\n"
####| each {
####   $"<p>\n($in)\n</p>"
####}
####| str join "\n"
####| wrap content
}


export def "infer table" [file: path, page: int, bbox: record<l,r,t,b>, ] {
    log info $"infering table from block ($bbox) page ($page) of ($file)"
    let inference = (
        pdf render --block $file $page $bbox --res $data_collection_resolution
        | surya-ocr infer table
    );

    let table_data = try {
        $inference | html parse table
    } catch {
        log warning "failed when trying to parse table data"
    };

    {
        content: $inference,
        data: $table_data,
    }
}

export def "infer image" [file: path, page: int, bbox: record<l,r,t,b>, ] {
    log info $"infering image from block ($bbox) page ($page) of ($file)"
    let render_image  = (
        pdf render --block $file $page $bbox --res $data_collection_resolution
    );


    {
        content: $"<img src=\"($render_image | image to b64url)\"></img>",
        image: $render_image
    }
}
