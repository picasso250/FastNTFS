param(
  [string]$TaskName = "EverythingGoMVP",
  [string]$InstallDir = "$env:ProgramData\EverythingGoMVP",
  [string]$Volumes = "C,D",
  [string]$Address = "127.0.0.1:7788",
  [int]$FlushSeconds = 10,
  [string]$DbPath = ""
)

$ErrorActionPreference = "Stop"

function Assert-Admin {
  $id = [Security.Principal.WindowsIdentity]::GetCurrent()
  $p = New-Object Security.Principal.WindowsPrincipal($id)
  if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Please run this script in an elevated (Administrator) PowerShell."
  }
}

Assert-Admin

$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $DbPath) {
  $DbPath = Join-Path $InstallDir "everything_mvp.db"
}

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
$LogDir = Join-Path $InstallDir "logs"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

$ExePath = Join-Path $InstallDir "everything-go-mvp.exe"
Write-Host "[1/4] Building binary..."
Push-Location $RepoDir
try {
  go build -o $ExePath .
} finally {
  Pop-Location
}

if (-not (Test-Path $ExePath)) {
  throw "Build failed: $ExePath not found."
}

Write-Host "[2/4] Writing service metadata..."
@"
TaskName=$TaskName
InstallDir=$InstallDir
Volumes=$Volumes
Address=$Address
FlushSeconds=$FlushSeconds
DbPath=$DbPath
InstalledAt=$(Get-Date -Format s)
"@ | Set-Content -Encoding UTF8 (Join-Path $InstallDir "install.info")

Write-Host "[3/4] Registering scheduled task..."
$argList = "serve --volumes $Volumes --db `"$DbPath`" --addr $Address --flush-seconds $FlushSeconds"
$action = New-ScheduledTaskAction -Execute $ExePath -Argument $argList -WorkingDirectory $InstallDir
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest -LogonType ServiceAccount
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Hours 0) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1)

if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
  Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings | Out-Null

Write-Host "[4/4] Starting task..."
Start-ScheduledTask -TaskName $TaskName
Start-Sleep -Seconds 2

$task = Get-ScheduledTask -TaskName $TaskName
$info = Get-ScheduledTaskInfo -TaskName $TaskName

Write-Host "Installed successfully."
Write-Host "TaskName: $TaskName"
Write-Host "State:    $($task.State)"
Write-Host "LastRun:  $($info.LastRunTime)"
Write-Host "DbPath:   $DbPath"
Write-Host "Address:  $Address"
Write-Host "Check:    http://$Address/status"
