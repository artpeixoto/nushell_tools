use ../env_utils/ *  ; 

export-env { default_env {
    auth: {
        path: ($nu.home-dir | path join ".local/share/auth")
    }
}} ; 

const element_pattern = '{name}.auth.json';

# export def "modules path" []: [nothing -> list<string>] { 
#     ls $env.auth.path | get name | each { path relative-to $env.auth.path } 
# }


export def "modules list" []: [nothing -> list<string>] { 
    ls $env.auth.path | get name | each { path relative-to $env.auth.path } 
}

export def "elements name_to_path" [] :   [ record<module: string , name: string> -> string ] {
    let input = $in; 
    let file_name = $input | format pattern $element_pattern ; 
    $env.auth.path | path join  $input.module $file_name 
}


export def "elements path_to_name" [] :   [ path -> record<module: string, name: string> ] {
    let path = $in;

    let path_parts = $path | path relative-to $env.auth.path  | path split ;
    let module = $path_parts | first ; 
    let item_path = $path_parts | skip 1 | path join ;   
    let item_name = $item_path | parse $element_pattern | get 0 | get name;
    return {
        module: $module,
        name: $item_name
    }
}

export def "elements list" [module: string@"modules list"] : [nothing -> list<string>] {
    [$env.auth.path, $module] | 
        path join | 
        ls $in | 
        get name | 
        path expand | 
        each { |name| 
            try {
                $name | elements path_to_name 
            } catch {|err| 
                null 
            }
        } | 
        where { is-not-empty } | 
        get name
} 

module cmds { 
    export def retrieve [module : string@"modules list", name: string@"elements list"] { 
        {module: $module, name: $name} | elements name_to_path | open $in 
    }

    export def store [module: string@"modules list", name: string, --force (-f)] { 
        let path = {module: $module, name: $name} | elements name_to_path ; 
        $in | save $path --force
    }

    export def list [module?: string@"modules list"]  { 
        if ($module | is-empty ) {  # list modules
            modules list
        } else {
            elements list $module
        }
    }
}
export use cmds * ; 