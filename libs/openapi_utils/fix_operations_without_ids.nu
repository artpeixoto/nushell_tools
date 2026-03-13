use ../kv_utils/ * ;
use std/random ;

export def main [] {
    mut api = $in;
    
    let paths = $api.paths | into kvs ;
    mut res = []
    
    for kvp in $paths {
        let path = $kvp.key ;
        mut path_data = $kvp.value;
        let make_req_id = {|method|
            let clean_path = $path | str replace --all -r '\{|\}|/' "_"
            $"($method)_($clean_path)"
        }

        for method in [ get post put patch options delete ] {
            if ($path_data not-has $method) { continue }

            mut req = $path_data | get $method ;
            let id = do $make_req_id $method ;
            $req.operationId = $id;
            $path_data = $path_data | update $method $req
        }  

        $res ++= [{key: $path, value: $path_data } ]
    }
    
    $api.paths = $res | from kvs
    $api
}