export def eq [relative_to: any] : [any -> bool] { $in == $relative_to }
export def neq [relative_to: any] : [any -> bool] { $in != $relative_to }
export def gt [relative_to: any] : [any -> bool] { $in > $relative_to }
export def ge [relative_to: any] : [any -> bool] { $in >= $relative_to }
export def lt [relative_to: any] : [any -> bool] { $in < $relative_to }
export def le [relative_to: any] : [any -> bool] { $in <= $relative_to }

export def neg [] : [bool -> bool] { not $in }
export def not [] : [bool -> bool] { not $in }

export def add [rhs : any] : [any -> any] {$in + $rhs}
export def sub [rhs : any] : [any -> any] {$in - $rhs}
export def mul [rhs : any] : [any -> any] {$in * $rhs}
export def div [rhs : any] : [any -> any] {$in / $rhs}
