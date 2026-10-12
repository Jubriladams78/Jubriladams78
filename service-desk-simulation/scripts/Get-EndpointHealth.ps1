<#
.SYNOPSIS
    First-look triage for "my computer is slow / acting weird" tickets.
    Collects disk, memory, uptime, pending reboot, top CPU processes, and
    network config into one screen to paste into the ticket.

.EXAMPLE
    .\Get-EndpointHealth.ps1
    .\Get-EndpointHealth.ps1 -ComputerName MHS-WS-0142
#>
[CmdletBinding()]
param([string]$ComputerName = $env:COMPUTERNAME)

$sb = {
    $os   = Get-CimInstance Win32_OperatingSystem
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"

    $pendingReboot = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
    ) | Where-Object { Test-Path $_ }

    $ip = Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway } | Select-Object -First 1

    [pscustomobject]@{
        Computer        = $env:COMPUTERNAME
        OS              = "$($os.Caption) $($os.Version)"
        UptimeDays      = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalDays, 1)
        PendingReboot   = [bool]$pendingReboot
        DiskC_UsedPct   = [math]::Round(100 - ($disk.FreeSpace / $disk.Size * 100), 1)
        DiskC_FreeGB    = [math]::Round($disk.FreeSpace / 1GB, 1)
        MemUsedPct      = [math]::Round(100 - ($os.FreePhysicalMemory / $os.TotalVisibleMemorySize * 100), 1)
        IPv4            = $ip.IPv4Address.IPAddress
        Gateway         = $ip.IPv4DefaultGateway.NextHop
        DNS             = ($ip.DNSServer.ServerAddresses -join ', ')
        TopCPU          = (Get-Process | Sort-Object CPU -Descending |
                           Select-Object -First 5 -ExpandProperty ProcessName) -join ', '
    }
}

$result = if ($ComputerName -eq $env:COMPUTERNAME) { & $sb }
          else { Invoke-Command -ComputerName $ComputerName -ScriptBlock $sb }

$result | Format-List

# Flags a technician should act on
if ($result.DiskC_UsedPct -ge 90) { Write-Warning 'C: drive above 90%. Run cleanup and check OneDrive offline files.' }
if ($result.UptimeDays   -ge 14) { Write-Warning 'Uptime 14+ days. Schedule a reboot with the user.' }
if ($result.PendingReboot)       { Write-Warning 'Pending reboot detected.' }
if ($result.IPv4 -like '169.254.*') { Write-Warning 'APIPA address. DHCP lease failed (see INC-1006).' }
