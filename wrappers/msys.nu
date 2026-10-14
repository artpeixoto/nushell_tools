export def main [] {
    shell --mingw64 
}

export def  --wrapped  --env "shell --mingw64" [...rest] {
    mingw64.exe -here -no-start -defterm ...$rest
}


