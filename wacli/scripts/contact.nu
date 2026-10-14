export def read [] : [string -> record] {
    let jid = $in
    ^wacli contacts show --jid $jid --json | from json | get data | update cells {default -e null}
}
export def me [] : [nothing -> record] {
    wacli auth status --json | from json | get data.linked_jid | read
}
