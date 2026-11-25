# 网易云音乐 API · Music Phase 0 调研

2026-11-25，基于指定部署的[文档入口](https://msapi.awup.cn/docs/#/?id=neteasecloudmusicapi)和 [Docsify 正文](https://msapi.awup.cn/docs/home.md)。实测 API Base URL 为 `https://msapi.awup.cn/`。URL 中的 /docs/ 和 # 后面的页面锚点均不属于 API 路由。此项目文档描述第三方部署；部署的匿名响应能力、数据和资源权限可能变化。

## 一、九个匿名请求的结果

请求方式均为 **GET**，HTTPS 默认信任校验，没有向服务发送账号、Cookie 或授权头。以下路径可直接拼接 Base URL 重现。九次均得到 HTTP 200、JSON 和顶层业务 code 200。样本是响应的字段白名单投影，数组最多保留一项；字段被裁剪不表示服务缺少该字段。没有下载音频或保存地址、歌词正文、用户资料、凭证。文档也描述 POST，本轮未验证 POST。

| 模块 | 请求路径与实参 | 实测响应、用途与限制 |
|---|---|---|
| Home | `/personalized?limit=1` | result 数组，id、name、trackCount、playCount。歌单 ID 17660040122 已超过有符号 32 位上限。[样本](samples/home.json) |
| Playlist | `/playlist/track/all?id=24381616&limit=1&offset=0` | songs 数组，另有 privileges。获取第一页的一条歌曲。offset 是跳过的条数，第二页应累加已取得的条数。[样本](samples/playlist.json) |
| Search | `/cloudsearch?keywords=Blue&type=1&limit=1&offset=0` | result.songs 与 result.songCount，本次总数 316。关键词变化应废弃旧页，分类切换须重置 offset。[样本](samples/search.json) |
| Player | `/song/detail?ids=347230` | songs[0] 为海阔天空，dt=326000 ms、ar 为歌手数组、al 为专辑对象。映射 SCTrack.duration 时除以 1000。[样本](samples/detail.json) |
| Player | `/check/music?id=347230` | success=true、message=ok。应判断 success；可用性结果不能证明能播放完整版。[样本](samples/availability.json) |
| Player | `/song/url/v1?id=347230&level=standard` | data[0] 存在 url，条目 code=200、type=MP3、br=128010、time=35030、expi=1200。条目时长与详情不一致，符合文档描述的试听情形，尚未用媒体引擎验证。只留非地址字段。[样本](samples/play.json) |
| Lyrics | `/lyric?id=347230` | lrc.lyric 非空，tlyric.lyric 无非空译文。还存在 klyric、romalrc 等键。可交给现有解析器；此样本仅留状态码。[样本](samples/lyrics.json) |
| Home 日推 | `/recommend/songs` | 本次匿名响应有 code 和 data；文档标为需登录，未确认 data 内有用户专属推荐。不作为游客首页依赖。[状态样本](samples/daily.json) |
| Player 边界 | `/song/detail?ids=0` | HTTP 和业务均成功，songs 为空。对请求指定 ID 的调用方应表达「未找到」，而非强取 firstObject 并开始播放。[样本](samples/missing-track.json) |

### 参数与字段契约

- `id` 是资源 ID；`ids` 是一个或多个十进制 ID，多个以逗号连接。查询串均由 serializer 编码。业务内可使用十进制字符串，收藏键宜区分来源与实体类型，防止本地预览及不同实体的 ID 冲突。
- `limit`、`offset`、搜索 `type`、Banner `type` 为整数语义。offset 从 0 起。keywords、cat、order、音质 level 为字符串。搜索默认 limit=30，类型 1/10/100/1000 对应歌曲/专辑/歌手/歌单。即使 HTTP 成功，也要校验预期根对象和当前类型的结果集合。
- `id/name` 标识实体，`ar[].id/name` 保留多位表演者，`al.id/name` 标识专辑。SCTrack 现在只有单一 artist；后续转换应约定主显示名与完整名单。artworkName 是本地资产名，远端封面应另存 URL。歌单 trackCount 表示服务报告的总曲数，不等于当前页的数组长度。
- 播放响应分别检查顶层状态、条目状态、url 是否为空、可用时长与授权范围。expi 是地址有效期信息，不能持久当作歌曲标识。全文和实际可播放时段可能不对齐，试听起止需要有依据后再映射歌词时间。未测试 Range、音频格式探测、后台播放或长期缓存资格。
- 文档称未登录或会员权限不足时可能只提供试听，部分曲目会因版权不可用。登录端点需要合法身份和 Cookie；本轮无登录验证。文档提到的业务 301 与 HTTP 重定向分别处理。匿名得到 200 不推广为免登录保证。
- 错误分层：传输失败或取消 → HTTP/MIME/JSON 解码错误 → 顶层业务错误 → 条目错误或空集合。仅空 ID 结果已实测；超时、过期地址、403、缺权限等留给本地 stub 或后续自然失败验证。
- `ids=0` 响应实际包含弱 ETag 与 Cache-Control: max-age=120。正文描述服务端按相同 URL 做短时缓存；该响应头不代表其他路由也有相同缓存策略。未发送条件请求，304 行为待验证。

## 二、其余业务接口目录

以下均来自指定服务文档，按文档的 GET 用法列出。**仅文档确认**，不将其标为当前部署已实测成功。登录类推荐必须单独处理。

| 模块与功能 | 路径 | 参数与分页注意 |
|---|---|---|
| Home 推荐新歌 | /personalized/newsong | limit 默认 10，不支持 offset；推荐歌单 /personalized 也不支持 offset |
| Home 每日推荐歌单 | /recommend/resource | 文档要求登录；与公共精选分类区分 |
| 热门歌单 | /top/playlist | order=hot 或 new、cat 分类名、limit 默认 50、offset |
| 排行榜 | /toplist | 取榜单 ID 后走 /playlist/detail；旧 idx 路由已弃用 |
| Banner | /banner | type=2 对应 iPhone |
| Playlist 分类 | /playlist/catlist、/playlist/hot | 全部分类与热门分类 |
| Playlist 详情 | /playlist/detail | id 必填，s 指最近收藏者数；文档提醒 tracks 可能不完整。分页使用上表实测的 /playlist/track/all |
| Search 默认词、热搜 | /search/default、/search/hot、/search/hot/detail | 无必需关键词，列表简略和详细版分开 |
| Search 联想 | /search/suggest | keywords，type=mobile 可选；需要与正式结果使用不同状态 |
| 分类搜索 | /search 或 /cloudsearch | keywords、type、limit、offset；仅 cloudsearch 的歌曲类型实测，其他分类返回字段待采样 |
| 播放地址旧版 | /song/url | id，可选 br；本阶段记录新版 standard 请求作为后续参考 |
| Artist 详情、热门曲 | /artist/detail、/artist/top/song | id 为歌手 ID；后者为热门 50 首接口 |
| Artist 专辑 | /artist/album | id、limit 默认 30、offset 默认 0 |
| Album 内容 | /album | id 为专辑 ID，详情与作品曲序应以后续实测为准 |

## 三、客户端接入点

工作区根目录有 AGENTS.md、开发路线图、阶段 QA 和学习笔记，未发现根 README.md。Spotify/Spotify.xcworkspace 通过 Pods 集成，工程目标 iOS 15.0。Podfile.lock 锁定 AFNetworking 4.0.1、YYModel 1.0.4、Masonry 1.1.0，LookinServer 1.2.8 仅 Debug。Spotify/server 当前是含 Resend 依赖的邮件测试目录，不是已接好的音乐代理。

| 当前实现 | 建议保留 | 接真实服务时首先解决的问题 |
|---|---|---|
| Common/Models/SCLocalMusicCatalog 组装曲目、歌手、专辑和歌单 | 保留本地目录作为可重复的预览输入 | 区分展示模型、接口 DTO、权限与临时播放资源，勿让 VC 遍历原始字典 |
| Home/Data/SCHomeDataProvider 实现 SCHomeDataProviding | 复用 section 与构造器注入 | 默认实现用固定下标和 subarray 组装首页；远端可返回不足一页，不能照搬切片 |
| Search/Models/SCSearchDataProvider 本地同步筛选 | 复用 SCSearchDataProviding 与控制器 requestNumber | 现有协议要求主线程交付；编号只处理旧结果，没有防抖、任务取消、分页或错误通道 |
| Playlist、Album、Artist 读取传入模型及本地目录 | 复用详情页、卡片、稳定 ID 路由 | 列表摘要不能保证内含详情，需按 ID 加载；歌手归属、曲序、总曲数、翻译缺失等逐项映射 |
| SCLibraryStore 使用本地 ID 和 NSUserDefaults 记录收藏/最近时间 | 保留收藏的唯一写入点 | 远端条目需可重新解析，避免把默认预览曲目或普通收藏当成服务端用户歌单 |
| Player/Services/SCPlaybackManager、Snapshot、Mini/全屏及队列 | 四种模式、索引映射、快照消费者；Lyrics parser 与二分定位 | 目前用 NSTimer + systemUptime 推进模拟时间；接 AVPlayer 时换进度来源并处理 item 生命周期、缓冲、失败和 seek 完成 |
| Storage 页读取容量，本地封面及 LRC 使用 Bundle | 复用读取与 UI 的分工 | 没有业务级 NSCache、磁盘 LRU、音频 Range 缓存、资源请求合并 |
| 首方源码未见 Core/Network 目录、统一 AF 客户端或 YYModel 映射调用 | 使用已安装依赖 | 首次抽象只围绕一个匿名 GET 建立；暂不需要 Repository、全 HTTP 动词集或新的缓存框架 |

第一组 YYModel 练习数据建议使用 detail.json、search.json 和 missing-track.json。预期结果为：同一展示模型从两种封装层取出；时长从毫秒转换到秒；无匹配曲目正常返回空结果。home.json 则能检出 32 位 ID 截断。歌词正文字段可用项目已有原创 LRC 做解析测试。
