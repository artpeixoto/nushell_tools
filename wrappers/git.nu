use ../kv_utils * ; 

export def --wrapped log [ ...rest ]: [] {
    let reg = '(?m)(?<id>[a-f0-9]+)( \((?<source>.*)\))?$\n(?<kwargs>(^\w+:\s+.+$)(\n(^\w+:\s+.+$))*)\n(?<message>(\s+.*$)(\n(\s+.*$))*)?';

    let things = (  
        ^git log --decorate=full ...$rest | 
        split row --regex "(?m)^commit " | 
        where {is-not-empty} | 
        parse --regex $reg | 
        select id source message kwargs 
    ) ;

    # print $things ;
    
    let kwargs = ( 
        $things.kwargs | 
        each { 
            lines | 
            parse --regex '(?<key>\w+)\s*:\s*(?<value>.+)' | 
            from kv | 
            rename --block {str snake-case} | 
            update date {into datetime} | 
            update author { parse --regex '^(?<name>.*?) <(?<email>.*?)>$' } 
        } 
    )  ;

    let entries = ( 
        $things | 
        reject kwargs | 
        zip $kwargs | 
        each { |x| $x.0 |  merge $x.1 } 
    );

    let entries = (
        $entries | 
        update message {
            lines | 
            each { str trim } |
            str join "\n"
        }
    );
    $entries 
}