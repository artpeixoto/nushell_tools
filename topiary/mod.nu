 #!/usr/bin/env -S  nu -l --stdin -c "main"
export-env {
    let prev = $env | get topiary --optional | default {} ;
    let default = {
        data: {
            path: ($env.HOME | path join ".config" "topiary")
        }
    }

    $env.topiary = $default | merge deep $prev;
}

export def --wrapped main [...rest] {
    $env.TOPIARY_CONFIG_FILE = ($env.topiary.data.path | path join  languages.ncl)
    $env.TOPIARY_LANGUAGE_DIR = ($env.topiary.data.path | path join  queries)
    $in | ^topiary ...$rest
}
