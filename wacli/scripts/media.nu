use kv_utils/ * ;
use pdf.nu ;
use cond_utils/ * ;
use iter_utils/ * ;
use cmp_utils/ * ;
use type_utils/ * ;
use std/log;
use media/ * ;
use ./base.nu *;

export module "of_msg" {

    export def download [
        msg?: record
    ] : [
        nothing -> path
        record -> path
    ] {
        let msg = $in | default {$msg} | default {error make "no msg informed"};

        log info $"downloading media for chat ( $msg.chat_jid ), message ($msg.id)";

        let asdf = do {
            mut dl_res =  (
                (^wacli media download
                    --chat $msg.chat_jid
                    --id $msg.id
                    --json
                ) o+e>| lines
                | last
                | from json
            );
            if (not $dl_res.success) {
                let err  = $dl_res.error | parse_single_download_err_msg  ;
                if ($err.type == "expired") {
                    $msg.timestamp
                } else {
                    error make {msg: $"failed to download msg: ($err | to json)" }
                }
            }

        }
        $asdf
    }

    export def "read" [msg: record] : [nothing -> oneof<path, nothing>] {
        log info $"searching store for media for chat ( $msg.chat_jid ), message ($msg.id)"
        let has_local = do {
            let has_local_path = $msg has local_path and ($msg.local_path | is-not-empty);
            if ( not $has_local_path ) {return false}

            let local_path_exists = ($msg.local_path | path exists) ;
            if (not $local_path_exists )  { return false }


            return true;
        }

        if $has_local {
            return $msg.local_path;
        } else {
            return null;
        }
    }

    export def "load" [
        msg: record
    ] {
        log info $"loading media for chat ( $msg.chat_jid ), message ($msg.id)"
        let res = read $msg;

        if $res != null {
            log info "it exists. will use it"
            return $res
        } else {
            log info "not found in store. will download it.";
            let res = download $msg;
            log info "done";
            return $res
        }
    }
}

export use of_msg;

export module of_chat {
    use std/log;


    export def "download" [
        chat_jid: string, --max = 50
    ]  {
        log info $"downloading media for chat ( $chat_jid ) ";
        ( ^wacli media backfill --chat $chat_jid --limit $max --workers 6 | lines | each { log info $in })
        ( ^wacli media retry    --chat $chat_jid --limit $max | lines | each { log info $in })
    }
}
export use of_chat;

export module of_chat_msgs {
    export def download [] : [table -> bool] {
        let msgs = $in;
        let chat_jid = $msgs.chat_jid | first;
        let to_download = ($msgs | where media_type != null | where local_path == null);

        if ($to_download | is-not-empty) {
            do {
                let to_download_count = $to_download | length;
                let download = {|dl_count|
                    (   ^wacli media backfill
                            --chat $chat_jid
                            --json
                            --limit $dl_count
                        o+e>| lines
                    )
                    | tee { each {log info ("media download: " ++ $in)} }
                    | str join "\n"
                    | parse_many_downloads_err_msgs
                };

                let dl_res = do $download $to_download_count;
                $dl_res | log info $"download results: \n($in | table -e)"

                if (not $dl_res.success) {  error make $"full failure: ($dl_res | to json)" }

                if ($dl_res.errors | is-empty) { return; }

                let to_download_count = $dl_res.data.failed + $dl_res.data.skipped;

                let msg_errors = $dl_res.errors  | where type == msg_err | get value;

                let expiration_errors = $msg_errors |  where { $in.error.type |  "expired" } ;

                if ($expiration_errors | is-not-empty) {
                    log info "gotten expiration errors. will send reupload request to phone";

                    let expired_count = $expiration_errors | length;
                    let msgs_map = $msgs | each {{key: $"($in.id)", value: $in}} | from kv;

                    let latest_expiration = (
                        $expiration_errors
                        | where { $msgs_map has ($in.msg_id) }
                        | each  {|err|
                            let msg_key = ($"($err.msg_id)")
                            $msgs_map
                            | get $msg_key
                            | get timestamp
                        }
                        | math max
                    );
                    let retry_res = (
                        ^wacli media retry
                            --chat $chat_jid
                            --limit $expired_count
                            --before ( $latest_expiration | format date "%F" )
                            --json
                    ) o+e>| lines | tee { each {log info $in}} | str join "\n" | parse_many_downloads_err_msgs ;
                    $retry_res | log info $"retry results: \n($in | table -e)"
                }
            };
            return true;
        } else {
            return false;
        }
    }
}

export use of_chat_msgs

export def parse_many_downloads_err_msgs [] {
    let lines = $in | lines;
    let review = $lines | last | from json ;

    let errors = $lines | drop 1 | each {|err|
        let parsed = $err | parse "media download failed for {chat_jid}/{msg_id}: {err_msg}" | first;
        if ($parsed == null) {return { type: unknown, value: $err } }
        let inner_err = $parsed.err_msg | parse_single_download_err_msg ;
        return {
            type: "msg_err",
            value:  {
                msg_id: $parsed.msg_id,
                chat_jid: $parsed.chat_jid,
                error: $inner_err
            }
        }
    };
    return {
        ...$review,
        errors: $errors
    }
}

export def parse_single_download_err_msg [] {
    let err_msg = $in;
    let sc_err =  $err_msg | parse "download failed with status code {status_code}" | first ;
    if ($sc_err != null) {
        return ( match ($sc_err.status_code) {
            "403" => {type: "expired"},
            "410" => {type: "expired"},
            "404" => {type: "not_downloaded_in_cellphone"},
            _ => {type: status_code, value: $sc_err.status_code }
        } )
    }
    let too_large_err =  $err_msg | parse "media too large ({media_size} bytes); maximum download is {max_size} bytes" | first;
    if ($too_large_err != null) {
        return {type: too_large}
    }

    return {type: unknown, value: $err_msg}
}


export def "store path" [] : [nothing -> path] {
    $env.wacli.store.path | path join "media"
}

# export def show [
#     id: record<chat_jid: string, msg_id: string>
# ] : [nothing -> path] {
#     let media_path = ( store path  | path join $id.chat_jid $id.msg_id );
#     log info $"searching local store for media for chat ( $id.chat_jid ), message ($id.msg_id) at ($media_path) ";
#     if ($media_path | path exists | not $in) {  return null;  }

#     let res =  do {
#         cd $media_path;
#         ls **/* --full-paths
#         | where type == file
#         | first
#         | get name --optional
#     }

#     $res
# }
