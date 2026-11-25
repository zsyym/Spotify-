# SpotifyClone 技术选型与核心技术分析

## 1. 技术栈决策

| 领域 | 选择 | 原因与边界 |
|---|---|---|
| UI | Objective-C + UIKit + Masonry | 与目标团队能力和 NLSpotify 经验一致，纯代码可测试、无 Storyboard 约束 |
| 音频 | AVFoundation/AVPlayer | 系统能力稳定，支持后台音频、seek、KVO、Now Playing 配合 MediaPlayer |
| HTTP | NSURLSession 自封装 | 减少第三方耦合，支持 request interceptor、取消、重试和网络状态 |
| JSON | YYModel 或轻量映射层 | 兼容 Objective-C；统一 Model 初始化，不把字典带入 UI |
| 图片 | SDWebImage（可选） | 封面内存/磁盘缓存，避免重复实现图片生命周期 |
| 布局 | Masonry | 纯代码约束；复杂列表可使用 UIKit FlowLayout |
| 本地库 | WCDB.objc/SQLite | 歌曲、歌单、下载和播放历史需要查询、事务和迁移 |
| WebSocket | SocketRocket 或 NSURLSessionWebSocketTask | P0 可选 SocketRocket；若最低系统和服务端允许，优先评估系统 WebSocket |
| 响应式 | 仅播放器/实时状态采用 ReactiveObjC（可选） | 不让全项目依赖信号；普通页面使用 block/delegate |
| 服务端 | Go 推荐 | goroutine、WebSocket 生态和并发模型适合房间服务；Node.js 也可作为团队熟悉方案 |
| Redis | 房间快照、成员、限流、Pub/Sub | 不作为唯一事实来源；关键状态落 MySQL |
| MySQL | 用户、歌单、房间、操作日志 | 事务、版本和审计记录 |
| Nginx | TLS、反向代理、WebSocket upgrade | 不承担房间状态 |
| MQ | P1 后使用 Kafka/RabbitMQ | 用于统计、周报、审计等异步任务；房间实时广播先走 Redis |

## 2. Service、Manager、Repository

- **Service**：一个业务能力或远端 API 的边界，例如 `SCSearchService`、`SCTogetherRoomService`。它无 UI 引用、尽量无全局状态。
- **Manager**：跨页面、长生命周期、需要协调系统资源的对象，例如 `SCMusicPlayerManager`、`SCWebSocketClient`、`SCAuthManager`。Manager 不负责展示。
- **Repository**：屏蔽 WCDB/SQLite 的 CRUD、事务和缓存策略。音乐库、协作歌单、搜索历史需要 Repository；纯一次性网络 DTO 不需要 Repository。
- **Delegate/Block**：一次性或父子关系回调；跨页面状态用观察接口/快照订阅，不用大量 Notification。

## 3. 播放器实现要点

`SCPlayerEngine` 内部持有 AVPlayer、time observer token 和 current item；`SCPlaybackQueueManager` 只处理队列，不知道 URL 加载细节；`SCMusicPlayerManager` 组合二者并暴露 `SCPlaybackSnapshot`。这样 Mini Player、全屏页、一起听房间和 CarPlay（后续）都依赖同一个门面。

进度使用 `CMTime` 转换；播放中的 UI 以 250–500ms 更新，TogetherListen 校准不直接依赖 UI tick，而使用 `SCPlaybackClock` 的单调时间。缓存采用 `AVAssetResourceLoaderDelegate` + HTTP Range；未完成文件 `.tmp`，完整后原子改名，元数据写入 WCDB。

## 4. 网络可靠性

`SCNetworkClient` 统一 base URL、编码、超时、取消和错误映射。`SCAuthInterceptor` 只允许一个刷新请求在飞，其他 401 请求进入等待队列，刷新成功后重放一次；超过次数转为登录失效。GET 可有限重试，带副作用的 POST 默认不自动重试，除非带幂等键。

WebSocket 与 HTTP 分离：HTTP 创建/加入/离开房间，WebSocket 传输房间事件；连接失败不自动修改房间数据。客户端发送 `client_message_id`，服务端去重。

## 5. 协作歌单并发

服务端以 `playlist_version` 作为乐观锁。客户端提交 `{base_version, operation_id, op}`；成功返回 `accepted_version` 和规范化操作。版本冲突返回 `409 PLAYLIST_VERSION_CONFLICT`，携带服务器快照和从 `base_version + 1` 开始的操作。客户端先合并远端操作，再重放本地未确认操作。

## 6. WebSocket 延迟校准

客户端收到 `server_time` 后用四次时间戳计算 RTT 和 offset：

```text
offset ≈ ((server_receive - client_send) + (server_send - client_receive)) / 2
server_now ≈ client_now + offset
expected_position = position_ms + (server_now - state_server_time)  (播放中)
```

若误差小于 250ms，平滑调整；250–1000ms 使用短时 rate correction；超过 1000ms 直接 seek。房主操作不会由客户端本地立即广播为事实，客户端可以乐观更新 UI，但必须等待服务器版本确认。

## 7. 测试策略

- 单元测试：Queue 的循环/随机边界、播放状态迁移、时间校准、协议编码、Repository CRUD、版本冲突合并。
- 集成测试：fake HTTP server、fake WebSocket transport、内存数据库；验证断线重连、重复消息、乱序消息和房主转让。
- UI 测试：Mini Player 与全屏页同步、搜索导航、歌单编辑、房间成员变化。
- 压测：服务端独立压测 WebSocket 连接、房间广播、Redis 热点和 MySQL 写入；没有测试数据前不宣称吞吐或延迟指标。
