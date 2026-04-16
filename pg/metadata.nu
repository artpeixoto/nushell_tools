use ./sql.nu ; 

def --env "cache store" [key : string]  { 
    let value = $in;
    $env.pg.cache = ($env.pg.cache? | default {}) | upsert $key $value;
}

def --env "cache retrieve" [key : string]  { 
    $env.pg.cache? | get $key -o
}


export def --env "list all" [
]: [
    nothing -> table<schema: string, name: string, type: string, owner: string>
] { 
    "\\d" | sql | rename --block {str snake-case }  
}

export def --env  "tables list" [
] {

    let data = "\\dt" | sql | rename --block {str snake-case } ;
    $data | cache store tables;
    $data
}

export def --env "tables inspect" [table: string] {
    $"\\d+ ($table)" | sql | rename --block {str snake-case} ;
} 

