use std/formats * ;
use kv_utils/ * ;
use pdf.nu ;
use cond_utils/ * ;
use iter_utils/ * ;
use cmp_utils/ * ;
use type_utils/ * ;
use std/log;
use media/ * ;
use ./base.nu * ;


def treat_msg_rows [] : [table -> table] {
    use ./contact.nu;
    use cond_utils/ * ;
    use iter_utils/ * ;

    let me = contact me;

    $in
    | rename --block {str snake-case}
    | rename --column {msg_id: id}
    | update timestamp {into datetime}
    | update cells { default --empty null }
    | each where {$in.from_me} {
        $in
        | update sender_jid $me.jid
        | update sender_name $me.name
    }
}

export def list [
    --chat: string,
    --limit: int,
    --time_start: datetime,
    --time_end: datetime,
] {
    use kv_utils/ * ;

    let parms = {
        "--chat": $chat
        "--limit": $limit
        "--before": ( $time_end     | do if {$in != null} {date to-timezone UTC | format date "%+"} )
        "--after":  ( $time_start   | do if {$in != null} {date to-timezone UTC | format date "%+"}  )
    }
    | into kv
    | where value != null
    | each { [$in.key, $in.value] }
    | flatten
    ;

    ( ^wacli messages list --json ...$parms )
    | from json
    | get data.messages
    | default {[]}
    | treat_msg_rows
    # | each {tee {print ( $in | describe )}}
}


export def read [
    id    : string,
    chat  : string,
] {
    ( ^wacli messages show --chat $chat --id $id --json )
    | from json
    | get data
    | [$in]
    | treat_msg_rows
    | first
}

export def add_transcriptions [] : [table -> table] {
    use ./media.nu;
    mut msgs = $in ;
    let downloaded_any = $msgs | media of_chat_msgs download  ;
    if ($downloaded_any) {
        $msgs = $msgs | each where {$in.media_type != null} {read $in.id $in.chat_jid}
    }

    let audios = (
        $msgs
        | where media_type == audio
        | where local_path != null
        | insert audio {get local_path | audio open}
        | each { { msg: $in.id , audio: $in.audio  }}
    );


    log info $"transcriptions requested for ($audios | length) messages with audio";
    log info $"downloaded audio message contents.";

    let transcriptions = (
        $audios.audio
        | audio transcribe many --model large-v3-turbo --language pt
        | each {get text }
        | zip $audios.msg
        | each {|r| {key: $r.1, value: $r.0}}
        | from kv
    );

    $msgs
    | each {|msg|
        if ($msg.media_type != audio) { return $msg }
        let transcription = $transcriptions | get ($msg.id) --optional ;

        if ($transcription == null) {return $msg}
        let msg = ($msg | insert transcription $transcription | move transcription --after text);

        if ( $msg.text == "[Audio]" ) {
            $msg | update text { $"[Audio Transcription] ($transcription)" }
        } else {
            $msg | insert transcription $transcription
        }
    }
}

export def media_id [] : [ record -> record<chat_jid: string, msg_id: string>] {
    {
        chat_jid: $in.chat.jid
        msg_id: $in.id
    }
}

export module "of_chat" {

    export def load [
        chat?: oneof<record<jid: string>, string>,
    ] : [
        nothing                            -> table,
        oneof<record<jid: string>, string>  -> table,
    ] {
        let chat_id = $in | default $chat | default { error make "no chat informed"} | chat_jid ;

        let state = {
            time: ( date now ),
            seen: []
        };
        generate {| state |
            let $new_chunk = do {
                let get_new_chunk = {
                    log info $"Getting history chunk. Searching for items before ($state.time | date humanize)";
                    let items = list --chat $chat_id --limit 50 --time_end $state.time

                    log info $"Gotten ($items | length) items";
                    if ($items | is-empty) { return [] }

                    let items =  $items | where id not-in $state.seen
                    log info $"after filtering, gotten ($items | length) items";
                    $items
                };

                mut $new_chunk = do $get_new_chunk;
                if ($new_chunk | is-empty)  {
                    log info "chunk came empty. will try downloading more";
                    $chat_id | download 50;
                    $new_chunk = do $get_new_chunk;
                }

                $new_chunk
            };

            if $new_chunk == [] { return { } };

            mut state = $state
            $state.time = $new_chunk | get timestamp | math min;
            $state.seen = ( ($new_chunk | get id | uniq )  ) ;

            {
                out: $new_chunk,
                next: $state
            }
        } $state
        | flatten
        | each { tee {
            print $in;
        }}
    }

    export def download [
        count = 200,
    ] : [ oneof<record<jid: string>, string> -> list ]  {
        let chat = $in;
        let chat_id = ($chat | chat_jid)
        let req_size = [$count, 50] | math min;
        let reqs = ( $count / $req_size ) | math ceil ;

        log info $"trying to download ($count) msgs for chat ($chat_id)";
        let tag = random int;
        let caller_job_id = job id;
        (  ^wacli history backfill
                --chat ($chat_id)
                --count ($req_size) --requests ($reqs)
                --events --json
                --idle-exit 5s --wait 20s
            o+e>| lines
        )
        | each {|line|
            try {
                return ( $line | from json )
            } catch {
                log warning $"($line)"; return null
            }
        }
        | where {is-not-empty}
        | each {|r|
            let  sleep_dur = 3sec * (random float );
            sleep $sleep_dur;
            return $r
        }
        | tee {  each { log info $"DOWNLOAD: ($in | to nuon)" }}
        | take while {|evt|
            if ($evt.event == "progress") {
                let enough = $evt.data.messages_synced >= $count;
                log info $"is enough: ($enough)";

                if ($enough ) {
                    return false;
                } else {
                    return true;
                }
            }
            return true;
        }
        | compact
        | tee {last | do {
            $in | let last ;
            if ( $last has success and $last.success == false ) {
                error make $last.error
            }
        } }
    }
}
export use of_chat  ;
