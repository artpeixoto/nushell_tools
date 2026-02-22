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