use ./open_nodes.nu *;

export def main [grammar: string] {
   $in
   | ^pest_cli ($grammar)
   | from json
   | open_nodes $in
   | get main
}
