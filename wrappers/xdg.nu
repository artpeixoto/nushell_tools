
export-env  {
    try { 
    let home = $env.HOMEPATH? | default {$nu.home-dir}
    let xdg = {
        bin: ($home)/.local/bin,
        config: ($home)/.local/config,
        data: ($home)/.local/share,
        state: ($home)/.local/state,
        cache: ($home)/.local/cache,
    }

    load-env {
        xdg : $xdg,
        XDG_DATA_HOME: $xdg.data,
        XDG_CONFIG_HOME: $xdg.config,
        XDG_STATE_HOME: $xdg.state,
    };

    $env.Path ++= [$xdg.bin];
    $env.Path  = $env.Path | uniq;

    }
    catch {|err| 
        $err |into string | print $in
    }
}   
