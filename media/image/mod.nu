use tools.nu *;
use type_utils/ *;
use std/log;
export def "image open" [path?: path]: [
  nothing -> record<content: binary, metadata: record<size: record<w: int, h: int>, type: string>>
  path -> record<content: binary, metadata: record<size: record<w: int, h: int>, type: string>>
] {
  let path = (
    $in
    | default $path
    | default { error make "no file given" }
    | path expand
  );

  let metadata = $path | image info;
  let type = $path | path parse | get extension;

  let content = open $path --raw;

  {
    content: $content
    metadata: {
      size: ($metadata.size)
      type: $type
    }
  }
}

export def "into image" []: [
  binary -> record<content: binary, metadata: record<size: record<w: int, h: int>, type: string>>
] {
  let metadata = $in | image info;

  {
    content: $in
    metadata: $metadata
  }
}

# these are from  imagemagick
export alias "magick op" = ^magick;

export def "image op crop" [rect: record]: [
  record<content: binary, metadata: record> -> record<content: binary, metadata: record>
] {
  let input_image = $in;
  let size = $rect | rect size;
  let rect_parm = $"($size.w)x($size.h)+($rect.l)+($rect.t)"
  let out_content = $input_image.content | magick op - -crop $rect_parm -;
  {
    content: $out_content
    metadata: {
      size: $size
      type: $input_image.metadata.type
    }
  }
}
export def "image show" []: [
  record<content: binary, metadata: record> -> nothing
] {
  get content | viu -w (30) -;
  sleep 100ms;
}

export def "rect size" []: record -> record<w: number, h: number> {
  let rect = $in;

  let size = {
    w: ($rect.r - $rect.l)
    h: ($rect.b - $rect.t)
  };
  $size
}

export def "rect intersect" [rect: record]: record -> record {
  {
    l: ([$in.l $rect.l] | math max)
    r: ([$in.r $rect.r] | math min)
    t: ([$in.t $rect.t] | math max)
    b: ([$in.b $rect.b] | math min)
  }
}

export def "rect move" [offset: record<x: number, y: number>]: record -> record {
  {
    l: ($in.l + $offset.x)
    r: ($in.r + $offset.x)
    t: ($in.t + $offset.y)
    b: ($in.b + $offset.y)
  }
}

export def "image save" [path: path]: [
  record<content: binary, metadata: record> -> path
] {
  let image = $in;

  let path: string = do {
    let im_ext = $image.metadata.type;
    let path_ext = $path | path parse | get extension;

    (
      if (($path_ext == $im_ext)) {
        $path
      } else {
        $"($path).($im_ext)"
      }
    )
  };

  log debug $"saving image to ($path | ansi link --type file)";

  $image.content
  | save $path --raw;

  $path
}

export def "image save_temp" []: [
  record<content: binary, metadata: record> -> path
] {
  let file = $in;
  let path = ignore | mktemp --suffix ($".($file.metadata.type)") --dry;
  $file | image save $path;
  $path
}

export def "image info" []: [binary -> record string -> record] {
  use type_utils/ *;
  let input = $in;
  let format_string = "%w %h %m"
  (
    if ($input | is string) {
      ignore | identify -format $format_string ($input | path expand)
    } else {
      $input | identify -format $format_string -
    }
  )
  | split column " "
  | rename w h m
  | first
  | do {
    $in | let data;
    {
      size: {
        w: ($data.w | into int)
        h: ($data.h | into int)
      }
      type: ($data.m | str lowercase)
    }
  }
}

export def --wrapped "magick info" [...rest]: [
  binary -> any
  string -> any
] {
  let input = $in;
  $rest | to json | print
  let magick_res = match (typeof $input) {
    string => {
      ignore | identify $input ...$rest
    }
    binary => {
      ignore | $input | identify ...$rest -
    }
  };
  $magick_res
}

export def "image to b64url" []: [
  record<content: binary, metadata: record<size: record, type: string>> -> string
] {
  $"data:image/($in.metadata.type);base64,($in.content | encode base64)"
}

export def "image pixels" [] {
  let image = $in;
  let out = (
    $image.content
    | magick - txt:
    | lines
  );

  let meta = $out | first | parse "# ImageMagick pixel enumeration: {w},{h},{p_depth},{format}" | first | do {|m|
      {
        size: {
          w: ($m.w | into int)
          h: ($m.h | into int)
        }
        pixel: {
          depth: ($m.p_depth | into int)
          format: $m.format
        }
      }
    } $in;

  mut data = 0..($meta.size.h) | each {
        0..($meta.size.w) | each {
        {r: 0.0 g: 0.0 b: 0.0 a: 0.0}
        }
    };

  for el in ($out | skip 1  | par-each { parse "{x},{y}: ({values})  #{_}  {_}" | first}) {
      let x = $el.x | into int
      let y = $el.y | into int
      let values = (
        $el.values
        | split column ","
        | first
        | update cells { into int | $in / $meta.pixel.depth }
        | rename r g b a
      );
      let cell_path = [$y, $x,] | into cell-path
      $data = $data | update $cell_path $values
  }

  {
    content: $data,
    metadata: $meta
  }
}
