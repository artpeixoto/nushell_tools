$env.config.history.file_format = "sqlite"
$env.config.history.max_size = 5_000_000
$env.config.history.sync_on_enter = true
$env.config.history.isolation = true
$env.config.show_banner = "none"
$env.config.rm.always_trash = true
$env.config.recursion_limit = 50
$env.config.edit_mode = "vi"
$env.config.buffer_editor = "hx"


$env.config.hooks.pre_prompt = []
$env.config.cursor_shape.emacs = "inherit"         
$env.config.cursor_shape.vi_insert = "blink_line"       
$env.config.cursor_shape.vi_normal = "blink_block"  

$env.PROMPT_INDICATOR_VI_NORMAL = ""         
$env.PROMPT_INDICATOR_VI_INSERT = ""         
$env.PROMPT_MULTILINE_INDICATOR = ""       
                                              
$env.TRANSIENT_PROMPT_COMMAND = ""          
$env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = ""                    
$env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = ""                    
$env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = ""                    
$env.TRANSIENT_PROMPT_COMMAND_RIGHT = ""       


$env.config.completions.algorithm = "fuzzy"
$env.config.completions.sort = "smart"
$env.config.completions.case_sensitive = false
$env.config.completions.quick = true
$env.config.completions.partial = true
$env.config.completions.use_ls_colors = true
$env.config.completions.external.enable = true
$env.config.completions.external.max_results = 50
$env.config.use_kitty_protocol = true
$env.config.shell_integration.osc2 = true
$env.config.shell_integration.osc7 = ($nu.os-info.name != windows)
$env.config.shell_integration.osc9_9 = ($nu.os-info.name == windows)
$env.config.shell_integration.osc8 = true
$env.config.shell_integration.osc133 = true
$env.config.shell_integration.osc633 = true
$env.config.shell_integration.reset_application_mode = true
$env.config.bracketed_paste = true
$env.config.use_ansi_coloring = "auto"
$env.config.error_style = "fancy"
$env.config.display_errors.exit_code = true
$env.config.display_errors.termination_signal = true
$env.config.footer_mode = 25
$env.config.table.mode = "rounded"
$env.config.table.index_mode = "always"
$env.config.table.show_empty = true
$env.config.table.padding.left = 1
$env.config.table.padding.right = 1

$env.config.table.trim = {
  methodology: "wrapping"
  wrapping_try_keep_words: false
}

$env.config.table.trim = {
  methodology: "truncating"
  truncating_suffix: "..."
}

$env.config.table.header_on_separator = false
$env.config.table.abbreviated_row_count = null
$env.config.table.footer_inheritance = false
$env.config.table.missing_value_symbol = "❎"
$env.config.datetime_format.table = null
$env.config.datetime_format.normal = "%m/%d/%y %I:%M:%S%p"
$env.config.filesize.unit = 'metric'
$env.config.filesize.show_unit = true
$env.config.filesize.precision = 1
$env.config.render_right_prompt_on_last_line = true
$env.config.float_precision = 2
$env.config.ls.use_ls_colors = true
$env.config.hooks.pre_prompt = []
$env.config.hooks.pre_execution = []
$env.config.hooks.env_change = {
    PWD: [{|before, after| null }]
}

$env.config.hooks.display_output = "if (term size).columns >= 100 { table -e } else { table }"

$env.config.hooks.command_not_found = []

$env.config.hooks.env_change = {}

$env.config.keybindings ++= [

  {

    name: insert_last_token

    modifier: alt

    keycode: char_.

    mode: [emacs vi_normal vi_insert]

    event: [

      { edit: InsertString, value: "!$" }

      { send: Enter }

    ]

  }

]

$env.config.keybindings ++= [

  {
    name: help_menu
    modifier: control
    keycode: char_h
    mode: [emacs, vi_insert, vi_normal]
    event: { 
      send: menu 
      name: help_menu
    }
  }
]

$env.config.menus ++= [

    {

        name: help_menu

        only_buffer_difference: true

        marker: "? "

        type: {

            layout: description

            columns: 4

            col_width: 20

            col_padding: 2

            selection_rows: 4

            description_rows: 10

        }

        style: {

            text: green

            selected_text: green_reverse

            description_text: yellow

        }

    }

]

$env.config.plugins = {

}

$env.config.plugin_gc.default.enabled = true

$env.config.plugin_gc.default.stop_after = 10sec

$env.config.plugin_gc.plugins = {
}

$env.config.highlight_resolved_externals = true


$env.ENV_CONVERSIONS = {
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

$env.ENV_CONVERSIONS = $env.ENV_CONVERSIONS | merge {
    "XDG_DATA_DIRS": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

const NU_LIB_DIRS = [
  ($nu.default-config-dir | path join 'scripts') 
  ($nu.data-dir | path join 'completions') 
  ($nu.data-dir | path join "nu_scripts") 
  ($nu.default-config-dir | path join 'libs') 
  ($nu.default-config-dir | path join 'modules'),  
]

$env.NU_LIB_DIRS = $NU_LIB_DIRS;

const NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins') 
]

$env.NU_PLUGIN_DIRS = $NU_PLUGIN_DIRS;

use std/util "path add"

# $env.PATH = [ "~/.local/bin" ] ++ $env.PATH


path add "~/.local/bin"
path add "~/.local/bin/dynamics/consultar_campos_de_entidades/"

$env.PATH = ($env.PATH | uniq)


use starship.nu ;
use cmp_utils * ;