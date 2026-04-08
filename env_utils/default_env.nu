
export def --env main [vars?]  { 
    let vars = $vars | default $in;
    let var_names = $vars | columns ;
    let env_names = $env | columns | where { $in in $var_names };
    let envs = if ($env_names | is-not-empty) {
        $env | select ...$env_names
    } else {
        {}
    }
    let to_load = $vars | merge deep $envs  ;

    load-env $to_load ; 
}
