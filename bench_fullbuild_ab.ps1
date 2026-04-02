param(
  [string]$Volume = "D",
  [string]$RustDir = "C:\Users\MECHREV\projects\everything-rs-mvp",
  [string]$GoDir = "C:\Users\MECHREV\projects\everything-go-mvp",
  [int]$MaxRecords = 50000000
)

$rustDb = Join-Path $RustDir "everything_mvp_rust_bench.db"
$goDb = Join-Path $RustDir "everything_mvp_go_bench.db"

Remove-Item -LiteralPath $rustDb -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $goDb -Force -ErrorAction SilentlyContinue

Write-Output "[RUST] full build start"
$rustElapsed = Measure-Command {
  Set-Location $RustDir
  cargo run -- ntfs-enum-db --volume $Volume --max-records $MaxRecords --db $rustDb
}
Write-Output ("[RUST] seconds=" + [Math]::Round($rustElapsed.TotalSeconds, 3))

Write-Output "[GO] full build start"
$goElapsed = Measure-Command {
  Set-Location $GoDir
  go run . full-build --volume $Volume --max-records $MaxRecords --db $goDb
}
Write-Output ("[GO] seconds=" + [Math]::Round($goElapsed.TotalSeconds, 3))

python -c "import sqlite3; r=sqlite3.connect(r'$rustDb'); g=sqlite3.connect(r'$goDb'); rc=r.execute('select count(*) from entries').fetchone()[0]; gc=g.execute('select count(*) from entries').fetchone()[0]; print('[RUST] entries=',rc); print('[GO] entries=',gc); r.close(); g.close()"

Write-Output "[DONE] benchmark complete"
