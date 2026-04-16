export def --env load [] : [
    record<host:string, user:string, password:string> -> nothing
] {
    let auth = $in ; 
    export-env { load-env {sql_server: {auth: $auth}} } 
}

alias external_parse = parse ;
alias external_format = format ; 

export def --env get [
    $auth?: oneof<record<host:string, user:string, password:string>, nothing >
] : [] {
    let auth = $auth | 
        default { $env.sql_server?.auth? } | 
        default { error make {msg: "no auth detected. either offer one directly or load it into the env" } }
    
    return $auth;
}

