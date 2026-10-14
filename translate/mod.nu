
export def main [--from = auto, --to = pt ] : [
    string -> string
] {
    {
        sl: $from,
        tl: $to,
        dt: t,
        client: gtx
        q: $in,
    }
    | url build-query
    | http get $"https://translate.googleapis.com/translate_a/single?($in)"
    | get 0.0.0
}
