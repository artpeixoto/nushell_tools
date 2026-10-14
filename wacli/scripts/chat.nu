use kv_utils/ * ;
use pdf.nu ;
use cond_utils/ * ;
use iter_utils/ * ;
use cmp_utils/ * ;
use type_utils/ * ;
use std/log;
use media/ * ;
use ./msg.nu;
use ./base.nu * ;

export def list [--limit = 10000] {
    ignore
    |^wacli chats list --json --limit $limit
    | from json
    | get data
    | update last_message_ts { into datetime }
}

export def read [] : [string -> oneof<record, nothing> ] {
    ^wacli chats show --jid $in  --json
    | from json
    | get data
    | update last_message_ts { into datetime }
}

export module msgs {
}

export use msgs;

export def dump [
    --count = 500,
    --add_transcriptions = true
] : [ ] {
    use msg;

    [$in]
    | flatten
    | each {|chat|
        log info $"Will start building the dump for chat ($chat.name).";
        mut msgs =  $chat  | msgs | take $count;
        log info $"Got ($msgs | length) messages";

        if $add_transcriptions {
            $msgs = $msgs | msg add_transcriptions
            log info $"Added transcriptions";

            # let to_download = (
            #     $msgs
            #     | where {get media_type --optional | is-not-empty }
            #     | where {get local_path --optional | is-not-empty }
            #     | length
            # );

            # $to_download | to json | log debug $in;

            # media download for chat $chat.jid --max $to_download;
        }

        $msgs = $msgs | reject chat_jid chat_name;

        let dump = {
            ...$chat
            msgs: $msgs
        };

        let dump_file_path = $"chat_($dump.name)_dump.json" | path expand;

        let dump_file_url = $"file://($dump_file_path)" | ansi link;

        log info $"storing dump to ($dump_file_url)";

        $dump | save $dump_file_path ;

        log info $"done with dumping of ( $dump.name )";

        $dump
    }
}
