use ./auth.nu ; 
use ./sql.nu  ;

export def get_schemas [
    --auth: record<host:string, user:string, password:string>, 
    --database: string,
] {
    mut cmd_auth = auth get $auth;

    if ( $database | is-not-empty ) {
        $cmd_auth = $cmd_auth | upsert database $database; 
    }
    
    let data = "select * from sys.schemas" | sql --auth $auth | rename --column {schema_id: id};
    return $data ;
}

# export def get_

export def get_tables [
    --auth: record<host:string, user:string, password:string>, 
    --database: string,
    --schema: string,
    --long (-l)
] : [
] { 
    mut cmd_auth = auth get $auth;

    if ( $database | is-not-empty ) {
        $cmd_auth = $cmd_auth | upsert database $database; 
    }
    
    let data = "select * from sys.tables" | sql --auth $auth ;

    if ($long)  { 
        return $data 
    } else { 
        return ($data |  get name)
    }
}


export def get_table_columns [
    table: string,
    --auth: record<host:string, user:string, password:string>, 
    --database: string,
    --long (-l)
] {

}
