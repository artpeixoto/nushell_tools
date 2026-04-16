use ./auth.nu ;
use ./sql.nu ; 

export def dump [
    --auth: record<host:string, user:string, password:string, database: string>, 
    --database: string,
    --output-path: string
    ...rest
] {
    mut auth = auth get $auth;
    let database = $database | default $auth.database? | default {"No database given."};

    $auth = $auth | reject database --optional ; 

    let path = $output_path | default { mktemp --dry --suffix ".bak" -t } ;
    let to_stdout = $output_path | is-empty

    "BACKUP DATABASE $(database) TO DISK = $(path); GO ; " | sql --auth $auth --vars {database: $database, path: $path}

    if ($to_stdout) { 
        let res = open $path --raw
        return $res;
    }
}