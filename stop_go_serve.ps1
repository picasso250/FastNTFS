Set-Location "C:\Users\MECHREV\projects\everything-go-mvp"
$pidFile = ".\go_serve.pid"
if (-not (Test-Path $pidFile)) {
  Write-Output "[INFO] pid file not found"
  exit 0
}

$pidRaw = Get-Content -Raw $pidFile
$pid = 0
[void][int]::TryParse($pidRaw.Trim(), [ref]$pid)
if ($pid -le 0) {
  Write-Output "[WARN] invalid pid in file"
  Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue
  exit 0
}

$p = Get-Process -Id $pid -ErrorAction SilentlyContinue
if ($p) {
  Stop-Process -Id $pid -Force
  Write-Output "[OK] stopped pid=$pid"
} else {
  Write-Output "[INFO] process already stopped, pid=$pid"
}

Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue
