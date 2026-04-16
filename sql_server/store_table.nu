use std/log;
use ./from_db.nu * ; 
use ./sql.nu ;

export def main [
    table_name: string, 
    --dest: path = "./.data", 
    --chunk_size (-c): int = 100_000 
] {
    let dest_folder = [$dest, $table_name , "data"] | path join; 
    
    if ($dest_folder | path exists ) {
        rm -r -f $dest_folder;
    }

    mkdir $dest_folder;
    const DATA_TAG = 0 ;
    const CONTROL_TAG = 1;
    let main_job = job id; 

    let store_job = job spawn {
        mut index = 0 ;
        mut data = []

        0.. | 
        each {|_| job recv --timeout 20sec } | 
        enumerate | 
        par-each {|c|
            let index = $c.index; 
            let data = $c.item;

            let table_file =   [$dest_folder $"chunk_($index).db"] | path join;       
            if ( $table_file | path exists ) {  rm $table_file -f; }

            log info $"storing chunk ($index)";

            $data | into sqlite $table_file;
        };
    } ;

    let parser_job = job spawn {
        let headers = job recv | parse_db_headers  ;
        log info $"headers are ($headers) "
        # skip stupid line
        job recv ;
        
        #now do it
        0.. | each { 
            0..50_000 | 
            par-each --keep-order {|_| job recv --timeout 5sec  | parse_db_row $headers} | 
            job send $store_job 
        };  
    } ;


    let sql_job = job spawn {
        $"select * from ($table_name)" | 
            sql --raw -s '|' | 
            lines | 
            each { job send $parser_job --tag $DATA_TAG }     
    };
}