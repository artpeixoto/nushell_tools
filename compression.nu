export def "compress" [
    --level = 5: int@"nu-complete compression-level"
]: [
    oneof<string, binary> -> binary
] {
  let level_str = match $level {
    1 => "-1"
    2 => "-2"
    3 => "-3"
    4 => "-4"
    5 => "-5"
    6 => "-6"
    7 => "-7"
    8 => "-8"
    9 => "-9"
  };
  $in | gzip --stdout $level_str --force | into binary
}

export def "decompress" []: [binary -> binary] {
  $in | gzip --stdout --decompress --force
}
export def "nu-complete compression-level" [] {
  return (
    1..9
    | each { into string }
    | collect
  )
}
