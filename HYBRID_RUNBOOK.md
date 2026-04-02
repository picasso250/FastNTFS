# Hybrid Runbook (Rust + Go)

## 0) Admin terminal required
All volume USN operations should run in an elevated terminal.

## 1) Save anchor (Go)
Run before full build to avoid missing changes during build window:

```powershell
cd C:\Users\MECHREV\projects\everything-go-mvp
go run . anchor --volume D --db C:\Users\MECHREV\projects\everything-rs-mvp\everything_mvp.db
```

## 2) Full snapshot build (Rust)

```powershell
cd C:\Users\MECHREV\projects\everything-rs-mvp
cargo run -- ntfs-enum-db --volume D --max-records 200000 --db .\everything_mvp.db
```

Alternative (Go full build, useful for A/B benchmark):

```powershell
cd C:\Users\MECHREV\projects\everything-go-mvp
go run . full-build --volume D --max-records 200000 --db C:\Users\MECHREV\projects\everything-rs-mvp\everything_mvp.db
```

## 3) Start incremental daemon (Go)

```powershell
cd C:\Users\MECHREV\projects\everything-go-mvp
go run . serve --volume D --db C:\Users\MECHREV\projects\everything-rs-mvp\everything_mvp.db --addr 127.0.0.1:7788 --poll-seconds 1 --flush-seconds 10
```

## 4) Query via client (Go)
Query triggers a flush before search:

```powershell
cd C:\Users\MECHREV\projects\everything-go-mvp
go run . search --addr http://127.0.0.1:7788 --query dota --limit 20
```

## 5) Quick status / flush

```powershell
curl http://127.0.0.1:7788/status
curl -X POST http://127.0.0.1:7788/flush
```

## Benchmark Baseline (2026-04-02, Volume D, low_usn=0)

- Rust full build: `6.45s`, `entries=242072`
- Go full build: `8.038s`, `entries=242072`
- Go full build (post-fix run): `7.26s`, `entries=242072`, `unresolved_parents=24`
