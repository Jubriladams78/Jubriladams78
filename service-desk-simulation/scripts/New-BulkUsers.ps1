<#
.SYNOPSIS
    Bulk-creates Active Directory users from an HR onboarding CSV.

.DESCRIPTION
    Meridian Health Systems service desk simulation (lab use).
    For each row: builds a unique sAMAccountName, creates the user in the
    correct OU, sets a temporary password that must be changed at first
    logon, and adds the user to their department security groups.
    Supports -WhatIf so you can preview every change first.

.EXAMPLE
    .\New-BulkUsers.ps1 -CsvPath ..\data\new_hires.csv -WhatIf
    .\New-BulkUsers.ps1 -CsvPath ..\data\new_hires.csv
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ })]
    [string]$CsvPath,

    [string]$Domain = 'corp.meridianhealth.lab',
    [string]$BaseDN = 'DC=corp,DC=meridianhealth,DC=lab',
    [string]$LogPath = ".\onboarding-$(Get-Date -Format yyyyMMdd-HHmm).csv"
)

Import-Module ActiveDirectory -ErrorAction Stop

function New-TempPassword {
    # 16 chars from a set without look-alike characters (0/O, 1/l/I)
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789!@#$%'
    -join (1..16 | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
}

function Get-UniqueSam {
    param([string]$First, [string]$Last)
    $base = ($First.Substring(0,1) + $Last).ToLower() -replace '[^a-z0-9]', ''
    if ($base.Length -gt 18) { $base = $base.Substring(0,18) }
    $sam = $base; $n = 1
    while (Get-ADUser -Filter "SamAccountName -eq '$sam'" -ErrorAction SilentlyContinue) {
        $n++; $sam = "$base$n"
    }
    $sam
}

$results = foreach ($row in Import-Csv $CsvPath) {
    $sam  = Get-UniqueSam -First $row.FirstName -Last $row.LastName
    $ou   = "OU=$($row.OU),$BaseDN"
    $pwd  = New-TempPassword
    $status = 'Created'

    try {
        if ($PSCmdlet.ShouldProcess("$sam in $ou", 'Create AD user')) {
            New-ADUser -Name "$($row.FirstName) $($row.LastName)" `
                -GivenName $row.FirstName -Surname $row.LastName `
                -SamAccountName $sam -UserPrincipalName "$sam@$Domain" `
                -Title $row.Title -Department $row.Department `
                -EmployeeID $row.EmployeeID -Path $ou `
                -AccountPassword (ConvertTo-SecureString $pwd -AsPlainText -Force) `
                -ChangePasswordAtLogon $true -Enabled $true -ErrorAction Stop

            foreach ($g in ($row.Groups -split ';' | Where-Object { $_ })) {
                Add-ADGroupMember -Identity $g.Trim() -Members $sam -ErrorAction Stop
            }
        } else { $status = 'WhatIf' }
    } catch {
        $status = "FAILED: $($_.Exception.Message)"
        Write-Warning "$sam -> $status"
    }

    # Passwords are NOT written to the log. Deliver them to the manager securely.
    [pscustomobject]@{
        EmployeeID = $row.EmployeeID
        SamAccount = $sam
        OU         = $row.OU
        Groups     = $row.Groups
        Status     = $status
        Timestamp  = Get-Date -Format s
    }
}

$results | Format-Table -AutoSize
if (-not $WhatIfPreference) { $results | Export-Csv $LogPath -NoTypeInformation }
