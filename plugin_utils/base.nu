use ../env_utils/ * ;  

export-env { 
    let default_plugin_path = ($nu.default-config-dir) | path join plugins;
    let default_plugin_bin_path = $default_plugin_path | path join bin;
    default_env {
        plugin : {
            path: $default_plugin_path
            bin: {
                path: $default_plugin_bin_path
            }
        }
    }
}
