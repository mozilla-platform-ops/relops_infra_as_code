<#
  AVD Session Init (runs per user at logon)
  Purpose:
    - Per-session hygiene safe to repeat
    - Hooks for future HKCU policy via Intune/GPO

  Intune/GPO notes:
    - Prefer delivering HKCU restrictions (e.g., browser policy, shell limits) via Intune Settings Catalog or GPO when available.
    - This script stays minimal to avoid slowing logon.
#>

$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference    = 'SilentlyContinue'

# 1) Clean volatile user temp (keeps Downloads intact)
try {
  if (Test-Path $env:TEMP) {
    Get-ChildItem "$env:TEMP" -Recurse -Force -ErrorAction SilentlyContinue |
      Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
  }
} catch {}

# 2) Optional: tighten per-session cache hygiene for browsers (commented)
#    Intune: Deploy Firefox enterprise policies instead of deleting caches here.
# try {
#   $ffProfilesRoot = Join-Path $env:APPDATA "Mozilla\Firefox\Profiles"
#   if (Test-Path $ffProfilesRoot) {
#     Get-ChildItem $ffProfilesRoot -Directory -ErrorAction SilentlyContinue | ForEach-Object {
#       $cachePaths = @(
#         (Join-Path $_.FullName "cache2"),
#         (Join-Path $_.FullName "startupCache")
#       )
#       foreach ($p in $cachePaths) {
#         if (Test-Path $p) { Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue }
#       }
#     }
#   }
# } catch {}

# 3) Optional: user shell hardening (commented placeholders)
#    Intune/GPO: HKCU Explorer policies (e.g., hide Control Panel items) should be set centrally.
# try {
#   $explHKCU = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
#   New-Item -Path $explHKCU -Force | Out-Null
#   # Example: Hide Run command
#   # New-ItemProperty -Path $explHKCU -Name 'NoRun' -Type DWord -Value 1 -Force | Out-Null
# } catch {}

# 4) Log a small audit breadcrumb (helps confirm execution)
try {
  if (-not (Get-EventLog -LogName Application -Source "AVD-SessionInit" -ErrorAction SilentlyContinue)) {
    New-EventLog -LogName Application -Source "AVD-SessionInit" -ErrorAction SilentlyContinue
  }
  Write-EventLog -LogName Application -Source "AVD-SessionInit" -EventId 100 -EntryType Information -Message "AVD session init ran for $env:USERNAME on $(hostname)"
} catch {}

exit 0
