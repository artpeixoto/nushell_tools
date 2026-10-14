use ./auth.nu ;
export def --wrapped dump [
    --auth: record<host:string, port:int, user:string, password:string, database: string>, 
    --schema=true,
    --data=false,
    ...rest
] {
    let auth = auth get $auth ;   
    if (not $schema and not $data) { 
        error make "both schema and data dump are deactivated";
    }

    let schema_dump = if $schema { 
        ( pg_dump 
            --dbname=($auth.database)
            --host=($auth.host)
            --port=($auth.port) 
            --username=($auth.user) 
            --schema-only
            ...$rest
        ) 
    } else {
        null 
    };

    let data_dump = if $data {
        ( pg_dump 
            --dbname=($auth.database)
            --host=($auth.host)
            --port=($auth.port) 
            --username=($auth.user) 
            --data-only
            ...$rest
        ) 
    } else { 
        null 
    }

    return $"($schema_dump) \n\n\n ($data_dump)"
}