# use ../kv_utils * ;
# use std/log;
# use ../str_utils/ *;

# export def  --wrapped main [
#     --auth: record, 
#     --raw,
#     --vars: record,
#     ...rest
# ] : [
#     string  -> table, 
#     nothing -> any
# ] {
#     let auth = $auth | default { $env.sql_server?.auth? } | default { error make {msg: "no auth detected. either offer one directly or load it into the env" } }
#     mut input = $in ; 
#     let interactive_mode: bool = $input | is-empty;
#     $input = $input | default "";

#     let encrypt_arg = if ($auth.encrypt? | default true) { "-E" } else {""}
#     mut args = [
#         "-r1",
#         $"-S", $"($auth.host)",
#         $"-U", $"($auth.user)", 
#         $"-P", $"($auth.password)",
#     ]; 

#     if ($auth.database? | is-not-empty) { $args ++= ["-d", $auth.database ] }
#     if ($auth.encrypt? | is-not-empty) {
#         $args ++= ["-N"]

#         if ($auth.trust_server_certificate? | default false) {
#             $args ++= ["-C"]
#         }
#     }

#     for kv in ($vars | each {into kv} | default []) {
#         $input = $":setvar ($kv.key) ($kv.value)\n" + $input 
#     }

#     $args ++= $rest;

#     if $interactive_mode {
#         (  sqlcmd  ...$args )
#     } else {
#         plugin use from_db;
#         if ($raw) { 
#             $input | 
#             sqlcmd ...$args 
#         } else {
#             $input | sqlcmd ...$args -s '|' | from db --drop_last_lines 2 

#         }
#     }
# }
 