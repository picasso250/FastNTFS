param(
  [string]$TaskName = "EverythingGoMVP",
  [switch]$RemoveFiles,
  [string]$InstallDir = "$env:ProgramData\EverythingGoMVP"
)

$ErrorActionPreference = "Stop"

if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
  Stop-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
  Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
  Write-Host "Removed scheduled task: $TaskName"
} else {
  Write-Host "Task not found: $TaskName"
}

if ($RemoveFiles) {
  if (Test-Path $InstallDir) {
    Remove-Item -LiteralPath $InstallDir -Recurse -Force
    Write-Host "Removed install directory: $InstallDir"
  } else {
    Write-Host "Install directory not found: $InstallDir"
  }
}
