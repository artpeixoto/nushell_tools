use std/log ; 
use std/config * ; 

use ../wrappers/direnv.nu ; 
# Initialize the PWD hook as an empty list if it doesn't exist
# $env.config.hooks.env_change.PWD = $env.config.hooks.env_change.PWD? | default []

# $env.config.hooks.env_change.PWD ++= [{||
#     if (which direnv | is-empty) { return }
#     if ( [.env .envrc] | any {path exists} | not $in ) { return; }

#     let direnv_export = (  direnv export json  ) ;

        
#     if ($direnv_export | is-not-empty) { 
#         log info $"direnv loaded.\n($direnv_export | table)"
#         $direnv_export 
#     }

#     # If direnv changes the PATH, it will become a string and we need to re-convert it to a list
#     $env.PATH = do (env-conversions).path.from_string $env.PATH
# }]
