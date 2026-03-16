
export def  --wrapped sql [
    conn_data: record<host:string, port:int, user:string, password:string, database?: string>, 
    ...rest
] : [
    string  -> table, 
] {
    let input = $in ; 
    let interactive_mode: bool = $input | is-empty;
    let database_parm = if ($conn_data.database? | is-empty) { "" } else {$"--dbname=($conn_data.database)"};
    $env.PGPASSWORD = ($conn_data.password);
   
    if $interactive_mode {
        (   ^psql 
            --host=($conn_data.host)
            --port=($conn_data.port) 
            --username=($conn_data.user) 
            $database_parm 
            ...$rest
        )
    } else {
        $input | 
        (   ^psql 
            --host=($conn_data.host) 
            --port=($conn_data.port) 
            --username=($conn_data.user) 
            --csv
            --field-separator='|'
            --quiet
            $database_parm 
            ...$rest
        ) | 
        from csv 
    }
}
