# SpotifyClone TogetherListen WebSocket 协议

## 1. 连接模型

HTTP 负责鉴权和房间生命周期：

```text
POST /v1/together/rooms
POST /v1/together/rooms/{room_id}/join
POST /v1/together/rooms/{room_id}/transfer-owner
POST /v1/together/rooms/{room_id}/close
DELETE /v1/together/rooms/{room_id}/members/me
GET /v1/together/rooms/{room_id}/snapshot
```

创建/加入成功后返回短期 WebSocket token。客户端连接：

```text
wss://realtime.example.com/v1/rooms/{room_id}?token=...
```

服务端完成鉴权后发送 `room.snapshot`。连接建立后双方每 20 秒发送心跳，服务端 45 秒未收到活动关闭连接。

## 2. 消息信封

所有消息使用 JSON 文本帧：

```json
{
  "type": "room.command.play",
  "message_id": "client-uuid",
  "room_id": "r_123",
  "sender_id": "u_9",
  "client_sent_at": 1730000000123,
  "base_version": 42,
  "payload": {}
}
```

字段规则：

- `message_id`：客户端 UUID，重试必须复用；
- `base_version`：发送者观察到的房间状态版本；
- `server_version`：服务端接受后递增；
- 时间全部为 Unix milliseconds；
- 服务端事件带 `server_sent_at` 和 `state_server_time`；
- 未知字段必须忽略，未知 type 返回 `error.unsupported_type`。

## 3. 客户端命令

### 播放控制

```json
{
  "type": "room.command.play",
  "base_version": 42,
  "payload": {"track_id":"t_88","position_ms":0}
}
```

支持：`play`、`pause`、`seek`、`next`、`previous`、`set_queue`、`set_play_mode`。只有房主可发送播放控制；是否允许成员添加歌曲由房间策略决定。

### 添加队列歌曲

```json
{
  "type": "room.command.queue_add",
  "base_version": 42,
  "payload": {"track_id":"t_99","after_track_id":"t_88"}
}
```

队列命令和播放命令分开，避免一个高频进度事件锁住队列修改。

### 成员/房主命令

`room.command.transfer_owner`、`room.command.leave`、`room.command.close`。关闭房间必须由房主发起，服务端广播后拒绝后续命令。

## 4. 服务端事件

服务端接受命令后广播规范化事件：

```json
{
  "type": "room.event.playback_state",
  "room_id": "r_123",
  "event_id": "e_100",
  "server_version": 43,
  "server_sent_at": 1730000000200,
  "state_server_time": 1730000000190,
  "payload": {
    "track_id":"t_88",
    "position_ms":1200,
    "is_playing":true,
    "play_mode":"queue",
    "owner_id":"u_9"
  }
}
```

其他事件：`room.snapshot`、`room.event.queue_changed`、`room.event.member_joined`、`room.event.member_left`、`room.event.owner_changed`、`room.event.closed`、`room.event.presence`、`error`。

### 版本同步

客户端发现 `server_version` 中间有缺口，或重连后只持有旧版本时，发送：

```json
{
  "type": "room.sync_request",
  "message_id": "client-sync-17",
  "room_id": "r_123",
  "payload": {"last_applied_version": 40}
}
```

服务端可返回增量事件；若事件已过保留窗口，则返回完整快照：

```json
{
  "type": "room.sync_response",
  "room_id": "r_123",
  "server_version": 43,
  "payload": {
    "mode": "snapshot",
    "snapshot": {"track_id":"t_88","position_ms":1200,"is_playing":true,"owner_id":"u_9"}
  }
}
```

## 5. 服务器权威状态

服务器保存：当前 track、position、playing、play mode、owner、queue 和 `state_version`。服务器收到房主命令时：

1. 校验 token、房间状态和操作者权限；
2. 用 `message_id` 去重；
3. 检查 `base_version`，过旧则返回 `error.version_conflict` 和最新 snapshot；
4. 在 Redis 原子更新快照并递增版本；
5. 写入异步事件日志；
6. 广播规范化事件。

客户端可以先更新按钮状态，但不能把本地 optimistic 状态作为最终事实。收到服务器事件后以事件版本覆盖；版本小于等于已应用版本的事件丢弃。

## 6. 进度同步与校准

播放中不需要每 100ms 广播。房主每 2 秒发送一次进度心跳，或在 seek/pause/play/切歌时立即发送。服务器使用接收时间计算新的 `state_server_time`，只广播节流后的状态。

客户端根据 RTT/offset 估算服务端当前时间：

```text
expected = position_ms + (estimated_server_now - state_server_time)
```

误差处理：

- `< 250ms`：正常播放，轻微 UI 修正；
- `250–1000ms`：短时间将 playback rate 调整到 0.98–1.02；
- `> 1000ms`：调用本地 Player seek；
- 当前歌曲不一致：先暂停、加载正确 track，再 seek 到服务器位置。

播放器未准备好时，客户端保存待执行快照，AVPlayer ready 后再校准。

## 7. 乱序、重复和断线

- 乱序：按 `server_version` 丢弃旧事件；对缺失版本发送 `room.sync_request`，服务端返回 snapshot。
- 重复：服务端以 `message_id` 幂等；客户端以 `event_id/server_version` 幂等。
- 断线：指数退避 1、2、4、8、16 秒，最大 30 秒并加入随机抖动；连接恢复后先发送 last_applied_version，服务端返回增量或完整 snapshot。
- 前后台：后台暂停高频进度发送，保留心跳；回前台立即 snapshot sync。
- 网络不可用：房间页面显示离线状态，禁止把本地控制伪装成已同步。

## 8. 房主掉线与冲突

房主连接断开后进入 15 秒 grace period；期间其他成员看到“房主重连中”，不接受新的播放控制。超时后服务器从在线成员中按加入时间最早者转让，写入 `owner_changed` 事件并广播。若没有在线成员，房间进入 suspended；房主重新加入可恢复，超过业务 TTL 后关闭。

多人同时控制时，只有房主命令能改变播放状态；成员的 `queue_add` 可按房间策略开放，服务端使用版本检查和顺序键解决冲突。客户端不直接互相广播控制消息。

## 9. Objective-C 客户端对象映射

- `SCWebSocketClient`：连接、发送、心跳、重连；
- `SCRealtimeEnvelope`：JSON 信封编码/解码；
- `SCTogetherRealtimeAdapter`：事件 type → 领域事件；
- `SCTogetherRoomService`：HTTP 创建/加入/离开/关闭；
- `SCTogetherRoomViewModel`：成员、房间状态、错误和权限展示；
- `SCMusicPlayerManager`：执行已确认的 `SCPlaybackCommand`。

`SCWebSocketClient` 不导入任何 ViewController；`SCMusicPlayerManager` 不知道 WebSocket。两者只通过 TogetherListen adapter 和 `SCMusicPlayerControlling` 协议连接。
