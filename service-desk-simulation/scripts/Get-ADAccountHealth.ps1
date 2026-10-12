<#
.SYNOPSIS
    Daily account health report for the service desk: locked, disabled-but-
    still-in-groups, stale (no logon in N days), and passwords about to expire.

.EXAMPLE
    .\Get-ADAccountHealth.ps1 -StaleDays 90 -ExpiringDays 7 -ExportPath .\health.csv
#>
[CmdletBinding()]
param(
    [int]$StaleDays = 90,
    [int]$ExpiringDays = 7,
    [string]$ExportPath
)

Import-Module ActiveDirectory -ErrorAction Stop

$now         = Get-Date
$maxPwdAge   = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
$props       = 'LockedOut','Enabled','LastLogonDate','PasswordLastSet',
               'PasswordNeverExpires','MemberOf','Department'
$users       = Get-ADUser -Filter * -Properties $props

$report = foreach ($u in $users) {
    $issues = @()

    if ($u.LockedOut) { $issues += 'Locked out' }

    if (-not $u.Enabled -and $u.MemberOf.Count -gt 0) {
        $issues += "Disabled but still in $($u.MemberOf.Count) group(s)"
    }

    if ($u.Enabled -and $u.LastLogonDate -and
        $u.LastLogonDate -lt $now.AddDays(-$StaleDays)) {
        $issues += "Stale: last logon $($u.LastLogonDate.ToString('yyyy-MM-dd'))"
    }

    if ($u.Enabled -and -not $u.PasswordNeverExpires -and $u.PasswordLastSet -and
        $maxPwdAge.TotalDays -gt 0) {
        $expires = $u.PasswordLastSet + $maxPwdAge
        $daysLeft = [math]::Floor(($expires - $now).TotalDays)
        if ($daysLeft -ge 0 -and $daysLeft -le $ExpiringDays) {
            $issues += "Password expires in $daysLeft day(s)"
        }
    }

    if ($issues) {
        [pscustomobject]@{
            User       = $u.SamAccountName
            Department = $u.Department
            Enabled    = $u.Enabled
            Issues     = $issues -join '; '
        }
    }
}

$report | Sort-Object Department, User | Format-Table -AutoSize -Wrap
Write-Host "`n$(@($report).Count) account(s) need attention." -ForegroundColor Yellow
if ($ExportPath) { $report | Export-Csv $ExportPath -NoTypeInformation }
