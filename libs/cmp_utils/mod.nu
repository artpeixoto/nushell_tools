export def eq [relative_to: any] : [any -> bool] { $in == $relative_to }
export def neq [relative_to: any] : [any -> bool] { $in != $relative_to }
export def gt [relative_to: any] : [any -> bool] { $in > $relative_to }
export def ge [relative_to: any] : [any -> bool] { $in >= $relative_to }
export def lt [relative_to: any] : [any -> bool] { $in < $relative_to }
export def le [relative_to: any] : [any -> bool] { $in <= $relative_to }