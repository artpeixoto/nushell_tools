use ./base.nu * ;

export def main [phone_number: string] {
    ( wacli auth
        --follow false
        --phone $phone_number
    )
}
