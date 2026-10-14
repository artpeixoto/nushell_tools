export def main [node: record] {
    use type_utils/ * ;
    let name = $node.rule | from json;
    let children = $node.inner;
    let value = match ($children | typeof) {
        string => {
            $children
        }
        record => {
            ($children.pairs | each {main $in})
        }
        _ => { null }
    }
    ({} | insert $name $value)
}
