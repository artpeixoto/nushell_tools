export def --env main [vars?]  { 
    let vars = $vars | default $in;
    print ($vars | table);
    let var_names = $vars | columns ;
    print ($var_names | table);
    let env_names = $env | columns | where { $in in $var_names };
    print $env_names;

    let envs = if ($env_names | is-not-empty) {$env | select ...$env_names} else {{}}
    print $envs;

    let to_load = $vars | merge deep $envs  ;

    print ($to_load | table); 
    load-env $to_load ; 
}