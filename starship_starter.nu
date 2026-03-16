use std/random ;
# this file is both a valid
# - overlay which can be loaded with `overlay use starship.nu`
# - module which can be used with `use starship.nu`
# - script which can be used with `source starship.nu`
# alias starship = ^'C:\Program Files\starship\bin\starship.exe';
def get_jobs_list [] { }
def get_common_args [] : nothing -> list<string> {
    let path_args = [--path, ( pwd )]
    let cmd_duration_args = [
        --cmd-duration , 
        (if $env.CMD_DURATION_MS == "0823" { 0 } else { $env.CMD_DURATION_MS }) 
    ];

    let jobs_list_args = if (which "job list" | where type == built-in | is-not-empty) {
        ["--jobs", (job list | length)]
        } else {
            []
        } 

    let status_args = [$"--status=($env.LAST_EXIT_CODE)"]
    let terminal_width_args = ["--terminal-width", ( (term size).columns | into string )]
    [
        ...$path_args,
        ...$status_args,
        ...$jobs_list_args,
        ...$terminal_width_args,
        ...$cmd_duration_args
    ]
}

def  get_command_prompt [] {
    	( starship prompt ...(get_common_args) ) 
        # + 
        # "\n"
        # (
        #     # The initial value of `$env.CMD_DURATION_MS` is always `0823`, which is an official setting.
        #     # See https://github.com/nushell/nushell/discussions/6402#discussioncomment-3466687.
        #     let cmd_duration = if $env.CMD_DURATION_MS == "0823" { 0 } else { $env.CMD_DURATION_MS };
        #     let jobs_list = get_jobs_list;
        #     ^'C:\Program Files\starship\bin\starship.exe' prompt
        #         --cmd-duration $cmd_duration
        #         $"--status=($env.LAST_EXIT_CODE)"
        #         --terminal-width (term size).columns
        #         ...(
        #             if (which "job list" | where type == built-in | is-not-empty) {
        #                 ["--jobs", (job list | length)]
        #             } else {
        #                 []
        #             }
        #         )
        # )
    } 

def get_command_indicator_prompt [mode:string]: nothing -> closure {
    let res = match $mode {
        "vim_insert" => {|| ( starship module "custom.vim_mode_ins" ...(get_common_args) )}
        "vim_select" => {|| ( starship module "custom.vim_mode_vis" ...(get_common_args) ) }
        "vim_normal" => {|| ( starship module "custom.vim_mode_nor" ...(get_common_args) ) }
        "vim_insert_cont" => {|| ( starship module "custom.vim_mode_ins_cont" ...(get_common_args) ) }
        "vim_normal_cont" => {|| ( starship module "custom.vim_mode_nor_cont" ...(get_common_args) ) }
    }

    return $res
}


def get_right_prompt [] {
        (
            # The initial value of `$env.CMD_DURATION_MS` is always `0823`, which is an official setting.
            # See https://github.com/nushell/nushell/discussions/6402#discussioncomment-3466687.
            let cmd_duration = if $env.CMD_DURATION_MS == "0823" { 0 } else { $env.CMD_DURATION_MS };
            starship prompt
                --right
                --cmd-duration $cmd_duration
                $"--status=($env.LAST_EXIT_CODE)"
                --terminal-width (term size).columns
                ...(
                    if (which "job list" | where type == built-in | is-not-empty) {
                        ["--jobs", (job list | length)]
                    } else {
                        []
                    }
                )
        )
    } 
def get_after_cmd [] {
    let status  =  starship module status ...(get_common_args)
    let fill    = starship module fill ...(get_common_args)
    let fill_size = (term size).columns - ($status | str length)
    let fill_str = seq 1 $fill_size | each {$fill} | str join
    "\n" + $status + $fill_str  
}

export-env { 
    $env.STARSHIP_SHELL = "nu"; 
    load-env {
        STARSHIP_SESSION_KEY: (random chars -l 16)
        # PROMPT_MULTILINE_INDICATOR: (
        #     ^'C:\Program Files\starship\bin\starship.exe' prompt --continuation
        # )

        # Does not play well with default character module.
        # TODO: Also Use starship vi mode indicators?


        config: ($env.config? | default {} | merge {
            render_right_prompt_on_last_line: false,
        })
        PROMPT_COMMAND              : {|| get_command_prompt}
        PROMPT_COMMAND_RIGHT        : {|| get_right_prompt}
        PROMPT_INDICATOR            : (get_command_indicator_prompt vim_normal)
        PROMPT_INDICATOR_VI_INSERT  : (get_command_indicator_prompt vim_insert)
        PROMPT_INDICATOR_VI_NORMAL  : (get_command_indicator_prompt vim_normal)
        PROMPT_MULTILINE_INDICATOR  : (get_command_indicator_prompt vim_normal_cont)
        TRANSIENT_PROMPT_COMMAND    : {|| get_after_cmd}
        TRANSIENT_PROMPT_INDICATOR  : "| "
        TRANSIENT_PROMPT_INDICATOR_VI_INSERT : "| "
        TRANSIENT_PROMPT_INDICATOR_VI_NORMAL : "| "
        TRANSIENT_PROMPT_MULTILINE_INDICATOR : "| "
    }
}
