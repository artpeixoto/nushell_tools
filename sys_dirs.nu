export module system {

}

export module user {
    export const home  = ($nu.home-dir);
    export const config  = ($home | path join ".config");

    export const data = ($home | path join ".local/share");
    export const state = ($home | path join ".local/state");
    export const var = ($home | path join ".local/var");
}

export use user * ;
