use kv_utils/ * ;
use pdf.nu ;
use cond_utils/ * ;
use iter_utils/ * ;
use cmp_utils/ * ;
use type_utils/ * ;
use std/log;
use media/ * ;

export-env {
    $env.wacli.store.path = $"~/.local/state/wacli/" | path expand;
}


module local {
    export def chat_jid [
    ] : [
        oneof<record<jid: string>, string>  -> string,
    ] {
        let chat = $in;
        match (typeof $chat) {
            string => {$chat},
            record => {$chat.jid}
            _ => {error make "chat aint got no jid"}
        }
    }
}


export use local * ;
