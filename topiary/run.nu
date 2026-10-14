let script = path self | path dirname | path join mod.nu;

$in | nu $script format
