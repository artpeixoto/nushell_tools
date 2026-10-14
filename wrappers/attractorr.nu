use ../str_utils/ *;

export def main [query: string] {
  (^attractorr $query 
  | lines 
  | split list "" 
  | where {$in 
  | is-not-empty } 
  | each {|lines|
    let first_line = $lines.0 ;
    let second_line = $lines.1;
    let first_line_data =  (
      $first_line 
      | parse "{seeders}/{leechers} - {name} ({source}, {size})" 
      | get 0
    );
    let url = $second_line;
    {...$first_line_data, url: $url}
  })
  | move name --first 
}
