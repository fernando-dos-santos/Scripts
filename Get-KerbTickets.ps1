<#
    .SYNOPSIS
        Displays a list of currently cached Kerberos tickets
    .NOTES
        e-mail: fernandopro2@gmail.com 
    .LINK
        https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/klist
  #>

# Run KLIST Utility
$output = klist

$mlString = $output | Out-String
$dateFormat = "yyyy-MM-dd hh:mm:ss"

$ticketHeader_regex = @"

(?ms)Current LogonId is (.+)

Cached Tickets: \(([0-9]+)\)

"@

$ticketInfo_regex = @"
(?ms)#[0-9]+>\s*Client:\s([\w0-9_\-.]+)\s@\s([\w0-9_\-.]+)
\s+Server:\s(\w+)\/([\w0-9_\-.]+)(\s@|\/[\w0-9_\-.]+]*\s@)\s([\w0-9_\-.]+)
\s+KerbTicket Encryption Type: ([\w0-9_\-.]+)
\s+Ticket Flags\s+([\w\d]+) -> ([\w_\s]+)
\s+Start Time:\s+(\d{1,2}\/\d{1,2}\/\d{4}\s\d{1,2}:\d{1,2}:\d{1,2}) \(local\)
\s+End Time:\s+(\d{1,2}\/\d{1,2}\/\d{4}\s\d{1,2}:\d{1,2}:\d{1,2}) \(local\)
\s+Renew Time:\s+(\d{1,2}\/\d{1,2}\/\d{4}\s\d{1,2}:\d{1,2}:\d{1,2}) \(local\)
\s+Session Key Type:\s+([\w0-9_\-.]+)
\s+Cache Flags:\s+([\w\d]+[\s\-\>\s\w]*)
\s+Kdc Called:\s([\w0-9_\-.]+)
"@

if($mlString -match $ticketHeader_regex){

    if($Matches[2] -ge 1){
        $CachedTickets = $Matches[2]

        $krbObj = @()

        foreach($i in (0..($CachedTickets-1))){
            $Matches = $null
            if(($output | Select-String -Pattern "#$($i)" -Context 9) -match $ticketInfo_regex){
                
                $props = [ordered]@{
                    Client =        $Matches[1]
                    Domain =        $Matches[2]
                    Service =       $Matches[3]
                    Server =        $Matches[4]
                    Encryption =    $Matches[7]
                    Flag =          $Matches[8]
                    Start =         Get-Date ( $Matches[10] -replace "(\d{1,2})\/(\d{1,2})\/(\d{4})",'$3-$1-$2') -Format $dateFormat
                    End =           Get-Date ( $Matches[11] -replace "(\d{1,2})\/(\d{1,2})\/(\d{4})",'$3-$1-$2') -Format $dateFormat
                    Renew =         Get-Date ( $Matches[12] -replace "(\d{1,2})\/(\d{1,2})\/(\d{4})",'$3-$1-$2') -Format $dateFormat
                    KeyType =       $Matches[13]
                    CacheFlags =    $Matches[14]
                    KDC =           $Matches[15]
                }

                $krbObj += New-Object -TypeName psobject -Property $props
            }
        }
        $krbObj
    }
}
