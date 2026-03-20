use ../env_utils/ * ;

export-env { default_env { 
    direnv: { 
        paths : {
            config: ($env.APPDATA | path join direnv config),
            cache : ($env.APPDATA | path join direnv cache),
            data  : ($env.APPDATA | path join direnv data),
        }
    }
    DIRENV_CONFIG : ($env.APPDATA | path join direnv config),
    XDG_DATA_HOME: ($env.APPDATA | path join direnv data),
    XDG_CACHE_HOME: ($env.APPDATA | path join direnv cache),
} };


# export def --wrapped main [...rest] { 
#     ( with-env {
#             XDG_DATA_HOME: $env.direnv.paths.data,
#             XDG_CACHE_HOME: $env.direnv.paths.cache,
#             DIRENV_CONFIG: $env.direnv.paths.config,
#         } { 
#             ^direnv ...$rest
#         } 
#     )
# }