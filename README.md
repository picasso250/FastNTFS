# FastNTFS

FastNTFS is a Windows NTFS file search daemon written in Go, backed by the USN journal and SQLite.  
FastNTFS 是一个运行在 Windows 上的 NTFS 文件搜索守护进程，使用 Go 编写，底层依赖 USN journal 和 SQLite。

## Features | 功能

- Full snapshot build from NTFS USN records  
  基于 NTFS USN 记录构建全量快照
- Incremental daemon updates from USN journal  
  基于 USN journal 持续增量更新
- Local HTTP search API and CLI search command  
  提供本地 HTTP 搜索接口和命令行搜索
- Windows scheduled-task based service install/uninstall  
  基于 Windows 计划任务的安装与卸载

## Requirements | 运行要求

- Windows (Administrator required for USN operations)  
  Windows（涉及 USN 操作时需要管理员权限）
- Go 1.24+  
  Go 1.24+
- NTFS volumes  
  NTFS 分区

## Quick Start | 快速开始

```powershell
cd C:\Users\MECHREV\projects\FastNTFS
go run . rebuild --volumes D --db C:\data\fastntfs.db
go run . serve --volumes D --db C:\data\fastntfs.db --addr 127.0.0.1:12345 --flush-seconds 10
go run . search --addr http://127.0.0.1:12345 --contains test --field name --type file --limit 20
go run . search --addr http://127.0.0.1:12345 --like '%test%' --field all --type all --limit 20
```

## Install as Service | 安装为服务

```powershell
cd C:\Users\MECHREV\projects\FastNTFS
.\install_service.ps1 -DbPath C:\data\fastntfs.db
```

Default behavior | 默认行为:

- Auto-detect and include all local NTFS volumes  
  自动探测并包含所有本地 NTFS 分区
- Build binary to `~/bin/fast-ntfs.exe`  
  将二进制构建到 `~/bin/fast-ntfs.exe`
- Rebuild full index before service starts  
  服务启动前先重建全量索引

Optional flags | 可选参数:

- `-Volumes D,E`
- `-SkipRebuild`
- `-MaxRecords 50000000`

## Search API | 搜索接口

- `GET /` and `GET /help`: return plain-text API help  
  `GET /` 和 `GET /help`：返回纯文本帮助信息
- `--contains <text>`: substring shortcut, rewritten to `LIKE '%text%'`  
  `--contains <text>`：子串快捷方式，内部会改写为 `LIKE '%text%'`
- `--like <pattern>`: raw SQL `LIKE` pattern such as `'%x%'`, `'%x'`, `x%'`  
  `--like <pattern>`：原始 SQL `LIKE` 模式，例如 `'%x%'`、`'%x'`、`'x%'`
- `--field name|path|all`  
  `--field name|path|all`
- `--type file|dir|all`  
  `--type file|dir|all`
- `format=text|json` on `/search` (`text` by default)  
  `/search` 支持 `format=text|json`（默认 `text`）
- `--contains` and `--like` are mutually exclusive  
  `--contains` 与 `--like` 互斥

Examples | 示例:

```powershell
curl "http://127.0.0.1:12345/"
curl "http://127.0.0.1:12345/help"
curl "http://127.0.0.1:12345/search?contains=rg.exe"
curl "http://127.0.0.1:12345/search?contains=rg.exe&format=json"
```

## Uninstall | 卸载

```powershell
.\uninstall_service.ps1
```
