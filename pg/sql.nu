export def  --wrapped main [
    auth?: record<host:string, port:int, user:string, password:string, database: string>, 
    ...rest
] : [
    string  -> table, 
    nothing -> any
] {

    let auth = $auth | default { $env.pg?.auth? } | default { error make {msg: "no auth detected. either offer one directly or load it into the env" } }

    let input = $in ; 
    let interactive_mode: bool = $input | is-empty;

    let database_parm = if ($auth.database? | is-empty) { 
        "" 
    } else {
        $"--dbname=($auth.database)"
    };

    $env.PGPASSWORD = ($auth.password);
   
    if $interactive_mode {
        (   ^psql 
            --host=($auth.host)
            --port=($auth.port) 
            --username=($auth.user) 
            $database_parm 
            ...$rest
        )
    } else {
        $input | 
        (   ^psql 
            --host=($auth.host) 
            --port=($auth.port) 
            --username=($auth.user) 
            --csv
            --quiet
            $database_parm 
            ...$rest
        ) | 
        from csv 
    }
}
 