use topiary/;

$env.config.keybindings ++= [
    {
        name: format_command_line
        modifier: control
        keycode: char_f
        mode: [vi_insert, vi_normal, emacs]
        event: [
            {
                send: ExecuteHostCommand ,
                cmd: "commandline | do {use topiary/; $in | topiary format --language nu }  | commandline edit -r $in"
            }
        ]
    }
]
