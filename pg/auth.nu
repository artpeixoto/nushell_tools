export def --env load [] : [
    record<host:string, port:int, user:string, password:string> -> nothing
] {
    let auth = $in ; 
    export-env { load-env {pg: {auth: $auth}} } 
}

alias external_parse = parse ;
alias external_format = format ; 

export def --env get [
    $auth?: oneof<record<host:string, port:int, user:string, password:string>, nothing >
] : [] {
    let auth = $auth | 
        default { $env.pg?.auth? } | 
        default { error make {msg: "no auth detected. either offer one directly or load it into the env" } }
    
    $env.PGPASSWORD = $auth.password ; 
    return $auth;
}
export module connection_string { 
    export const pattern = 'postgresql://{user}:{password}@{host}:{port}/{database}';

    export def format [] : [] {
        $in | external_format pattern $pattern
    }

    export def parse [] : [] {
        # postgresql://postgres:[YOUR-PASSWORD]@db.ihlhygwyxowgqhgmnxgp.supabase.co:5432/postgres
        let res =  $in | external_parse $pattern | first | update port {into int} ;
        return $res
    }
}
