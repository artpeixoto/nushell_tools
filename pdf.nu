use media/ * ;
use std/dirs ;
use std/log;
use type_utils/ * ;
use cond_utils/ *;
use cmp_utils/ * ;
use file/ ;
use kv_utils/ * ;
use tools.nu * ;

const res = 150;
export def "extract text --block" [
    $src_path: path
    $page: int,
    $rect: record<t: number, l: number, b: number, r: number>
    --res = $res
] : [
    nothing -> string
] {
    let src_path = $src_path | path expand;

    log info $"extracting text from file at block ($src_path):($page):[( $rect )]";


    let text = (   pdftotext
            -r $res
            ...(poppler_block_parms $rect $page)
            -f ( $page + 1 )
            $src_path -
    );

    $text
}

export def "render --block" [
    src_path: path
    page: int,
    rect: record<t: number, l: number, b: number, r: number>
    --res: int = ($res)
] : [
    nothing ->  record<
        content: binary,
        metadata: record<
            size: record,
            type: string
        >
    >
] {
    let src_path = $src_path | path expand;

    log debug $"rendering file block ($src_path):($page):[( $rect )]";

    let output = (
        pdftocairo
        ...(poppler_block_parms $rect $page)
        -singlefile
        -f  ( $page + 1                  | $"( $in )")
        -png
        -r $res
        $src_path -
    ) ;

    let render = $output | into image;

    $render
}

export def "render" [ file?: path , --res: int = $res] : [
    oneof<nothing, string> -> list<
        record<
            content: binary,
            metadata: record<
                size: record,
                type: string
            >
        >
    >
] {
    let file = $in | default { $file } | default {error make "no input" } | path expand;

    log debug $"rendering file ($file)";

    let info = $file | info;

    0..<$info.pages
    | each {$in +  1}
    | par-each --keep-order {|p|
        log debug $"rendering file ($file) page ($p)";
        (pdftocairo
            -png
            -f $p
            -singlefile
            -r $res
            $file -
        )
        | into image
    }
}

export def "extract images" [] {
    use std/dirs ;
    let src_path = $in | path expand --no-symlink ;

    let dir = mktemp -d;
    cd $dir;

    pdfimages -png $src_path "img";

    ignore
    | ls img-*.png
    | tee {log info $"found ($in | length) images"}
    | get name
    | wrap path
    | insert ix {get path | parse "img-{ix}.png" | first | get ix}
    | sort-by ix
    | get path
    | each {path expand}
    | collect
}

def poppler_block_parms [rect: record, page: int] : nothing -> list<string> {
    def to_poppler_dim [] : number -> int {
        $in  | math round | into int
    }

    let size = {
        w: ($rect.r - $rect.l),
        h: ($rect.b - $rect.t)
    };

    [
        -x,  ( $rect.l | to_poppler_dim   | $"( $in )")
        -y,  ( $rect.t | to_poppler_dim   | $"( $in )")
        -W,  ( $size.w | to_poppler_dim   | $"( $in )")
        -H,  ( $size.h | to_poppler_dim   | $"( $in )")
        -cropbox
    ]

}

export def info [file?: path] : [
    nothing -> record,
    path -> record
] {
    let file = $in | default $file | default { error make "no input"}  | path expand;

    pdfinfo $file
    | lines
    | split column ":" -n 2
    | rename key value
    | upsert value {default ""}
    | update value? {str trim}
    | update key {str snake-case}
    | from kv
    | update pages {into int}
}
