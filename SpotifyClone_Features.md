# SpotifyClone 功能与特色方案

## 1. 产品范围

### P0 首发范围

- 登录/游客模式、首页推荐、搜索、音乐库和个人资料基础页；
- 歌曲/专辑/歌手/歌单统一数据模型；
- AVPlayer 播放、队列、暂停、切歌、进度拖动、随机/单曲循环；
- Mini Player、全屏播放器、歌词和锁屏控制；
- 收藏歌曲、创建歌单、播放历史；
- 一起听房间的创建、邀请码加入、房主控制、成员列表、断线重连。

### P1 提升完成度

- 协作歌单的添加/删除/排序和版本冲突提示；
- 预加载、Range 缓存、离线已缓存歌曲；
- 一起听延迟测量、播放进度校准、房主转让；
- 搜索历史、热门搜索、推荐反馈；
- 听歌时长事件和周报基础统计。

### P2 进阶

- 房间内聊天、表情和投票；
- 智能 DJ、相似歌曲召回、个性化排序；
- 热点房间治理、跨设备接管、服务端回放和审计；
- 关注/粉丝动态、公开房间发现。

## 2. Home

`SCHomeService` 请求推荐歌单、专辑、热门歌曲和最近播放；`SCHomeViewModel` 将结果转换为 section view data。推荐可分为个性化、最近播放、热门、编辑精选四类，每个 section 由 `SCSectionView` + 横向 `UICollectionView` 承载。点击卡片只产生 `SCNavigationIntent`，由路由器打开详情页。

首次版本允许本地 mock 推荐；真实个性化推荐需要用户行为事件和后端召回服务。最近播放可以本地 Repository 起步，再异步上传统计。

## 3. Search

`SCSearchService` 统一支持 track、artist、album、playlist 四种类型；搜索栏输入经过 250ms debounce，先显示本地历史和热门搜索，再请求远端建议。结果页使用分段 Header 或 `UICollectionViewCompositionalLayout`，而不是让每个结果类型各自维护一套导航。建议接口为 `GET /v1/search?q=&types=track,artist,album,playlist&cursor=` 和 `GET /v1/search/hot`，结果统一映射为 `SCSearchResultSection`。

搜索历史由 `SCSearchHistoryRepository` 保存，最多保留 20 条；热门搜索由服务端返回并带 TTL。无网络时可以查询本地最近收藏和历史歌曲。

## 4. Library

音乐库展示收藏歌曲、专辑、歌手、我的歌单、最近播放和下载。`SCLibraryService` 只组合多个 Repository，不让 Controller 直接访问数据库。歌单详情统一使用 `SCPlaylistDetailViewController`，远程歌单和本地协作歌单通过 data source 协议区分。

## 5. Player

播放器功能拆为三个对象：

- `SCMusicPlayerManager`：对业务提供播放门面，维护当前快照、生命周期和外部事件；
- `SCPlaybackQueueManager`：维护不可变队列、当前索引、播放模式和队列操作；
- `SCMusicPlayerService`：负责获取可播放 URL、歌词、封面和缓存策略；
- `SCPlayerEngine`：只适配 AVPlayer 的加载、播放、暂停、seek 和时间观察。

播放入口统一为 `playQueue:index:`、`playTrack:`、`pause`、`skipNext`、`seekToProgress:`。Mini Player 和全屏播放器只订阅快照，不直接访问 AVPlayer。

## 6. Playlist 与协作歌单

普通歌单 CRUD 由 `SCPlaylistService` + `SCPlaylistRepository` 负责。协作歌单增加 `playlist_version` 和操作日志：客户端先使用本地版本提交操作，服务器用 `base_version` 做乐观并发检查；版本不匹配时返回最新快照和冲突操作，客户端重新应用未确认操作。

排序操作使用明确的 `move` 命令（song_id、before_song_id、base_version），避免传递整张歌单数组。服务端在事务中更新顺序并广播规范化后的新版本。

## 7. TogetherListen

### 用户流程

1. 用户点击“一起听”，调用 `POST /rooms` 创建房间；服务端返回 `room_id`、6 位邀请码和房主身份。
2. 其他用户输入邀请码，调用 `POST /rooms/{id}/join`，得到当前快照和 WebSocket token。
3. 房主选择歌曲或队列后发送播放命令；服务器验证权限、递增 `state_version` 并广播。
4. 所有客户端以服务器 `server_time`、`position_ms`、`is_playing` 和 `track_id` 校准本地播放。
5. 房主掉线后进入短暂 grace period；超时按照成员加入时间或服务端选定策略转让房主。

### 一起听的客户端边界

`SCTogetherRoomViewModel` 只处理房间页面展示；`SCTogetherRoomService` 处理 HTTP 房间 API；`SCTogetherRealtimeAdapter` 把 WebSocket 信封转换成 `SCPlaybackCommand`、`SCRoomMemberChange` 等领域事件。它通过 `SCMusicPlayerControlling` 调用 Player，避免 TogetherListen 导入 `SCPlayerEngine`。

## 8. Profile 与智能播放

Profile 首版包含头像、昵称、关注/粉丝列表和听歌统计。统计事件采用批量上报：播放超过 30 秒或达到歌曲 50% 才记为有效播放，客户端本地暂存，网络恢复后上传。

本地可实现：最近播放、基础时长统计、简单智能随机（过滤近期重复、偏好收藏）。后端支持：相似歌曲召回、用户画像、跨设备历史、周报聚合和推荐排序。不要在客户端伪造“个性化推荐”，没有行为数据时应标记为编辑精选或 mock。
