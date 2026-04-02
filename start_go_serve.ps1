Set-Location "C:\Users\MECHREV\projects\everything-go-mvp"

$pidFile = ".\go_serve.pid"
$stdoutLog = ".\go_serve.stdout.log"
$stderrLog = ".\go_serve.stderr.log"
$dbPath = "C:\Users\MECHREV\projects\everything-rs-mvp\everything_mvp.db"

# If pid file exists and process is alive, skip restart.
if (Test-Path $pidFile) {
  $oldPidRaw = Get-Content -Raw $pidFile
  $oldPid = 0
  [void][int]::TryParse($oldPidRaw.Trim(), [ref]$oldPid)
  if ($oldPid -gt 0) {
    $p = Get-Process -Id $oldPid -ErrorAction SilentlyContinue
    if ($p) {
      Write-Output "[INFO] go serve already running, pid=$oldPid"
      exit 0
    }
  }
}

$cmd = "Set-Location 'C:\Users\MECHREV\projects\everything-go-mvp'; go run . serve --volume D --db '$dbPath' --addr 127.0.0.1:7788 --poll-seconds 1 --flush-seconds 10"

$proc = Start-Process -FilePath "powershell" `
  -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", $cmd) `
  -RedirectStandardOutput $stdoutLog `
  -RedirectStandardError $stderrLog `
  -PassThru

Set-Content -Encoding UTF8 $pidFile $proc.Id
Write-Output "[OK] started go serve in background, pid=$($proc.Id)"
