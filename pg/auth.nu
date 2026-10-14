use ../cmp_utils *;
export def --env load [] : [
    record<host:string, port:int, user:string, password:string> -> nothing
] {
    let auth = $in ;
    log info $"loading pg auth data: ($auth | to json)"

    export-env { load-env {pg: {auth: $auth, cache: {}}} }
}

alias external_parse = %parse ;
alias external_format = %format ;

export def --env get [
    $auth?: oneof<record<host:string, port:int, user:string, password:string>, nothing >
] : [] {
    let auth = $auth |
        default { try_get } |
        default {}

    $env.PGPASSWORD = $auth.password ;
    return $auth;
}

export def error_not_loaded [] {
    error make {msg: "no auth detected. either offer one directly or load it into the env" } ;
}

export def validate_loaded [] {
    if ( not ( is_loaded ) ) {
        error_not_loaded;
    }
}


export def is_loaded [] : [nothing -> bool] {
    let auth: oneof<record, nothing> =   try_get;
    ( $auth | is-not-empty  )
}

export def try_get [] : [nothing -> oneof<record, nothing>] {
    let auth: record =   $env.pg?.auth?
    return $auth;
}

export def --env ensure_loaded [
    default_auth_getter: closure
] {

    let is_loaded = is_loaded;
    if (not $is_loaded ) {
        do $default_auth_getter | load ;
    }
    get
}

export def --env update_loaded [
    updater: closure
]  {
    validate_loaded ;
    get | do $updater | load
}

export module connection_string {
    export const pattern = 'postgres://{user}:{password}@{host}:{port}/{database}';

    export def format [] : [] {
        $in | external_format pattern $pattern
    }

    export def parse [] : [] {
        let res =  $in | %parse $pattern | first | update port {into int} ;
        return $res
    }
}

# postgresql://postgres:[YOUR-PASSWORD]@db.ihlhygwyxowgqhgmnxgp.supabase.co:5432/postgres
