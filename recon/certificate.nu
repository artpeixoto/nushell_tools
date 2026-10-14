export def search [domain: string] {
    {q: $domain, output: "json"} | url build-query
    | http get $"https://crt.sh/?($in)" --raw
    | from json
}
