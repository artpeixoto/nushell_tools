export module system {

}

export module user { 
    export const home  = ($nu.home-dir);
    export const config  = ($home | path join "AppData/Roaming");
    export const config_secondary = ($home | path join ".config/")

    export const ata = ($home | path join "AppData/Local");
    export const data_secondary = ($home | path join ".local/");

    export module auths {
        export const path = ($home | path join ".local/share/auth")
    }
}

export use user * ; 