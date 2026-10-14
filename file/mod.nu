use field_container_utils/ *;
use kv_utils/ *;
use cond_utils/ *;
use cmp_utils/ *;

def --wrapped inner_file [...rest]: [path -> any list<path> -> list<any>] {
  $in | each { ^file ...$rest --brief -f - }
}

def assert_path_input [inp1: oneof<string, nothing> inp2: oneof<string, nothing>] {
  let input = $inp1 | default $inp2;
  return $input
}

export def --wrapped "mime" [path?: path ...rest]: oneof<path, nothing> -> record {
  let input = assert_path_input $path $in;

  let res = (
    $input
    | inner_file --mime ...$rest
    | parse "{major_mime}/{minor_mime}; charset={charset}"
    | first
  );

  return {major: $res.major_mime minor: $res.minor_mime}
}

export def --wrapped "charset" [path?: path ...rest] {
  let input = assert_path_input $path $in;

  let res = $input | inner_file --mime ...$rest | parse "{major_mime}/{minor_mime}; charset={charset}" | first;

  return $res.charset
}

export def "show" [path?: path --long ...rest]: [path -> record nothing -> record] {
  let path = assert_path_input $path $in;
  let base_type = $path | path type
  let ls_data = (
    if ($base_type == dir) {
      ls $path --directory --long --mime-type --full-paths | first
    } else {
      ls $path --long --mime-type --full-paths | first
    }
  )
  let mode = ($ls_data.mode | from mode_str);
  let executable = $mode | values | any { get execute };
  let base_data = {
    path: $ls_data.name
    type: $base_type
    mime: ($ls_data.type | from mime_string --relaxed)
    size: $ls_data.size
    mode: $mode
    executable: $executable
    owner: ($ls_data | select user group)
    dates: ($ls_data | select created accessed modified)
  };

  if $long {
    let extra_data = (
      exiftool -charset UTF8 -j -- $path
      | from json
      | first
      | rename --block { str snake-case }
      | reject --optional ...[
        source_file
        exif_tool_version
        file_name
        directory
        file_size
        file_modify_date
        file_access_date
        file_inode_change_date
        file_permissions
        file_type
        file_type_extension
      ]
      | update field mime_type? { {key: mime value: ($in | from mime_string)} }
      | update field mime_encoding? { {key: encoding value: $in} }
    )

    $base_data | merge $extra_data
  } else {
    $base_data
  }
}

export def "to mode_string" [] {
}

export def "from mode_str" [] {
  def parse_chunk []: list<string> -> record {
    def parse_char [flag: string]: string -> bool {
      let input = $in;
      if $input == "-" {
        false
      } else if $input == $flag {
        true
      } else {
        error make "invalid character";
      }
    }

    let chunk = $in;
    {
      read: ($chunk.0 | parse_char r)
      write: ($chunk.1 | parse_char w)
      execute: ($chunk.2 | parse_char x)
    }
  }

  let chunks = (
    $in
    | split chars
    | chunks 3
    | each { parse_chunk }
  );

  {
    user: $chunks.0
    group: $chunks.1
    other: $chunks.2
  }
}

export def "content_id" []: [path -> binary] {
  let path = $in;
  let content = open $in --raw | into binary;
  let length = $content | bytes length;
  let hash = $content | hash md5 --binary;

  return ($hash ++ (length | into binary));
}

export def "from mime_string" [--relaxed]: [string -> oneof<record, string>] {
  let mime_string = $in;
  let parse_res = (
    $mime_string
    | parse "{major}/{minor}"
    | first
  )
  if $parse_res == null {
    if $relaxed {
      $mime_string
    } else {
      error make $"couldn't parse mime string ($mime_string)"
    }
  } else {
    $parse_res
  }
}
