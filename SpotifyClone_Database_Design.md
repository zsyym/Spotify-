# SpotifyClone 数据库与 Redis 设计

## 1. 数据分层原则

MySQL 是服务端事实来源；Redis 保存短生命周期房间状态、在线成员、幂等键和限流计数；iOS 本地 WCDB 保存离线 UI、播放历史、下载任务和缓存元数据。音频文件本身进入沙盒缓存，不存进数据库。

## 2. MySQL 表结构

### users

| 字段 | 类型 | 说明 |
|---|---|---|
| id | BIGINT PK | 用户 ID |
| nickname | VARCHAR(64) | 昵称 |
| avatar_url | VARCHAR(512) | 头像 |
| created_at/updated_at | DATETIME | 时间 |
| status | TINYINT | 正常/封禁 |

### tracks

`id` 为平台歌曲 ID；保存 title、artist_name、album_id、cover_url、duration_ms、source、copyright_status。播放 URL 不长期存储，可保存短期 provider_key 或由 Service 重新解析。

### playlists / playlist_tracks

`playlists`：id、owner_id、name、cover_url、visibility、is_collaborative、version、created_at、updated_at。  
`playlist_tracks`：playlist_id、track_id、position_key、added_by、added_at、deleted_at，主键为 `(playlist_id, track_id)`；排序使用可比较的 `position_key`，避免每次移动重写全部行。

### playlist_operations

id、playlist_id、operation_id UNIQUE、base_version、accepted_version、actor_id、operation_type、payload_json、created_at。用于协作歌单审计、重放和冲突诊断。

### playlist_members

playlist_id、user_id、role、joined_at；role 为 owner/editor/viewer。协作歌单权限与一起听房间权限分开。

### user_likes / listening_history / listening_events

- `user_likes(user_id, target_type, target_id, created_at)`：歌曲、专辑、歌手、歌单统一喜欢关系。
- `listening_history(user_id, track_id, played_at, duration_ms, completed)`：近期播放查询。
- `listening_events(id, user_id, track_id, started_at, listened_ms, client_id)`：异步统计明细，按时间分区或归档。

### together_rooms / together_room_members / room_events

- `together_rooms`：room_id、invite_code UNIQUE、owner_id、status、state_version、created_at、closed_at。
- `together_room_members`：room_id、user_id、role、last_seen_at、joined_at、left_at。
- `room_events`：room_id、event_id、state_version、event_type、actor_id、payload_json、created_at；用于审计和故障恢复，实时读取不依赖它。

关键约束和索引：

- 登录标识（邮箱或第三方 subject）必须唯一；昵称是否唯一由产品规则决定。
- `playlist_operations` 对 `(playlist_id, operation_id)` 建唯一约束；`(playlist_id, accepted_version)` 建唯一约束，保证版本只提交一次。
- `together_rooms.invite_code` 建唯一索引；`room_events` 建 `(room_id, state_version)` 和 `(room_id, created_at)` 索引；成员表建 `(room_id, left_at)` 索引便于在线成员查询。
- `listening_history` 建 `(user_id, played_at DESC)`；日志表按时间分区前必须以真实数据量验证收益。

## 3. iOS WCDB 表

本地表建议使用 `SC` 前缀模型：

- `SCLocalTrack`：track_id、title、artist、cover_url、play_url、duration_ms；
- `SCLocalPlaylist`、`SCLocalPlaylistTrack`：本地创建/收藏歌单和关系；
- `SCListeningHistory`：track_id、played_at、listened_ms；限制本地保留最近 200 条；
- `SCDownloadTask`：track_id、url、status、bytes_written、total_bytes、error_code；
- `SCAudioCacheInfo`：url_hash、total_length、cached_ranges、last_accessed_at；
- `SCSearchRecord`：keyword、searched_at；最多 20 条；
- `SCOutboxEvent`：协作歌单离线操作、operation_id、retry_count、status。

数据库通过 `SCDatabaseManager` 初始化，`SCTrackRepository`、`SCPlaylistRepository`、`SCDownloadRepository` 和 `SCSearchRepository` 对外提供 CRUD。Repository 必须提供事务方法，禁止页面直接拼 SQL。

## 4. Redis 数据结构

### 房间快照

```text
Key: room:{room_id}:state
Type: HASH
Fields:
  state_version, track_id, position_ms, is_playing,
  play_mode, state_server_time, owner_id, updated_at
TTL: 房间关闭后 1 小时
```

### 成员集合

```text
room:{room_id}:members      SET user_id
room:{room_id}:member:{id}  HASH role,last_seen_at,connection_id
room:{room_id}:connections  SET connection_id
```

### 邀请码

```text
room:invite:{invite_code} -> room_id
TTL: 房间生命周期 + 1 小时
```

### 去重与幂等

```text
room:{room_id}:event:{client_message_id} -> accepted event/version
SET NX, TTL 24h
playlist:{playlist_id}:op:{operation_id} -> accepted_version
SET NX, TTL 7d
```

### 限流

使用 Redis `INCR` + 短 TTL 或 Lua 脚本：用户连接创建、邀请码尝试、房间控制命令、协作歌单写操作分别设置窗口。限流只保护入口，不能替代权限校验。

## 5. 一致性与备份

房间实时状态以 Redis 为热状态、MySQL `room_events` 为审计；状态更新使用 Lua/事务保证版本递增和幂等检查。Redis 重启后可从最近事件或关闭前快照恢复。MySQL 做定期备份；统计事件进入 MQ 后异步聚合，避免播放主链路等待报表写入。
