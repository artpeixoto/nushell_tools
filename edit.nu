export def main [] { 
    let file = mktemp --suffix ".nu" --dry ; 
    exec $"($env.EDITOR? | default $env.config.buffer_editor)" $file;
    if ($file | path exists) { 
        open $file --raw | commandline edit $in --insert --accept
    }
}