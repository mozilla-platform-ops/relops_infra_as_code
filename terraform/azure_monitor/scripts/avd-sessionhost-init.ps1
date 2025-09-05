param()

$ProgressPreference = 'SilentlyContinue'

# --- AVD Agent & Bootloader only (no FSLogix) ---
$RegistrationToken = "${registration_token}"

$agentUri     = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv"
$bootUri      = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH"
$agentMsiPath = "$env:TEMP\AVD-Agent.msi"
$bootMsiPath  = "$env:TEMP\AVD-Bootloader.msi"

Invoke-WebRequest -Uri $agentUri -OutFile $agentMsiPath
Invoke-WebRequest -Uri $bootUri  -OutFile $bootMsiPath

Start-Process msiexec.exe -ArgumentList "/i `"$agentMsiPath`" /quiet REGISTRATIONTOKEN=$RegistrationToken" -Wait
Start-Process msiexec.exe -ArgumentList "/i `"$bootMsiPath`"  /quiet" -Wait

Write-Host "AVD agent installed and registered."

# --- Stateless profile hygiene ---

# Delete local user profiles on restart if older than 1 day
$polRoot = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
If (-not (Test-Path $polRoot)) { New-Item -Path $polRoot -Force | Out-Null }
New-ItemProperty -Path $polRoot -Name "DeleteUserProfilesOlderThanDays" -Value 1 -PropertyType DWord -Force | Out-Null

# Daily cleanup task to remove non-special, unused profiles older than 1 day
$cleanupScriptPath = "C:\ProgramData\AVD\Cleanup-UserProfiles.ps1"
New-Item -ItemType Directory -Path (Split-Path $cleanupScriptPath) -Force | Out-Null

@'
$cutoff = (Get-Date).AddDays(-1)
Get-CimInstance -ClassName Win32_UserProfile |
  Where-Object {
    -not $_.Special -and
    $_.LocalPath -and
    (Test-Path $_.LocalPath) -and
    ($_.LocalPath -notmatch '\\(Default|Public|Administrator)$') -and
    ($_.LastUseTime -ne $null) -and
    ([Management.DateTimeConverter]::ToDateTime($_.LastUseTime) -lt $cutoff)
  } |
  ForEach-Object {
    try {
      if (-not $_.Loaded) {
        Write-EventLog -LogName Application -Source "AVD-Cleanup" -EventId 1000 -EntryType Information -Message "Deleting profile: $($_.LocalPath)"
        $_ | Remove-CimInstance -ErrorAction Stop
      }
    } catch {
      Write-EventLog -LogName Application -Source "AVD-Cleanup" -EventId 1001 -EntryType Warning -Message "Failed to delete profile $($_.LocalPath): $($_.Exception.Message)"
    }
  }
'@ | Set-Content -Path $cleanupScriptPath -Encoding UTF8

try { New-EventLog -LogName Application -Source "AVD-Cleanup" -ErrorAction SilentlyContinue } catch {}

$action    = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$cleanupScriptPath`""
$trigger   = New-ScheduledTaskTrigger -Daily -At 3:00AM
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName "AVD-Daily-ProfileCleanup" -Action $action -Trigger $trigger -Principal $principal -Force | Out-Null

Write-Host "Stateless profile policies applied (delete on reboot + daily cleanup)."