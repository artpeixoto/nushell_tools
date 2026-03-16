export def --wrapped "image list" [...rest] {
    ^docker image ls ...$rest | 
    from ssv |
    rename --block {str snake-case} | 
    rename image name
}

export def --wrapped "container list" [...rest] {
    ^docker container ls ...$rest | 
    from ssv | 
    rename --block {str snake-case} | 
    rename container name
}

export alias "container ls" = container list

export alias "tui" = oxker


export def --wrapped "image history" [image: string, ...rest] : [nothing -> table<comment: string, created_at: datetime, layer: string, created_since: string, id: oneof<string, nothing>, size: filesize>] {
    use std/formats "from ndjson"
    
    ^docker image history $image --no-trunc --format json ...$rest |
        from ndjson |
        reverse | 
        rename --block { str snake-case } |
        update created_at { into datetime } |
        update size {into filesize} |
        update id {$in | let id ; if $id == "<missing>" { null } else {$id} }|
        rename --column {created_by: layer_cmd}

        
}