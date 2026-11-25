# SpotifyClone 架构设计

## 1. 设计目标与边界

SpotifyClone 是一个 Objective-C + UIKit 的音乐客户端，目标是保留 Spotify 风格的信息层级和播放体验，同时增加多人一起听、协作歌单和可扩展服务端接口。本方案借鉴 NLSpotify 已验证的页面和播放器经验，但重新划分模块边界：业务模块通过协议依赖能力层，播放器、网络、持久化和 WebSocket 不直接暴露实现细节。

约束：iOS 13+、纯代码 UIKit、Masonry、无 Storyboard；ViewController 只负责视图生命周期、用户事件和导航；业务逻辑放在 Feature Service、UseCase、Repository 或 Manager 中。

## 2. 完整目录树

```text
SpotifyClone/
├── Application/
│   ├── AppDelegate.h/.m                 应用级初始化
│   ├── SceneDelegate.h/.m               Window、登录态根路由
│   ├── SCAppRouter.h/.m                 登录/主界面/强制退出切换
│   ├── SCTabBarController.h/.m           首页、搜索、音乐库、个人资料
│   └── SCEnvironment.h/.m                dev/staging/prod 配置
├── Base/
│   ├── Controllers/SCBaseViewController
│   ├── Views/SCBaseView、SCEmptyView、SCLoadingView
│   ├── Cells/SCBaseTableViewCell、SCBaseCollectionViewCell
│   ├── Models/SCPage、SCError、SCPagination
│   ├── Protocols/SCLoadable、SCIdentifiable、SCSectionPresentable
│   ├── Categories/UIView+SCLayout、NSString+SCFormat
│   └── Theme/SCTheme、SCFont、SCColor、SCMetric
├── Core/
│   ├── Networking/
│   │   ├── SCNetworkClient.h/.m          NSURLSession 统一封装
│   │   ├── SCRequest.h/.m、SCResponse.h/.m
│   │   ├── SCAuthInterceptor.h/.m       token 刷新、请求重放
│   │   └── SCNetworkReachability.h/.m
│   ├── Player/
│   │   ├── SCMusicPlayerManager.h/.m     全局播放门面
│   │   ├── SCMusicPlayerService.h/.m     音源、歌词、封面和缓存协调
│   │   ├── SCPlaybackQueueManager.h/.m   队列和播放模式
│   │   ├── SCPlaybackState.h             状态/事件枚举
│   │   ├── SCPlayerEngine.h/.m           AVPlayer 适配器
│   │   ├── SCNowPlayingCoordinator.h/.m  锁屏与远程命令
│   │   ├── SCPlaybackClock.h/.m          本地单调时钟和校准
│   │   └── SCCacheResourceLoader.h/.m    可选 Range 缓存
│   ├── Persistence/
│   │   ├── SCDatabaseManager.h/.m
│   │   ├── SCModelStore.h/.m             WCDB/SQLite 访问门面
│   │   ├── Repositories/                只放跨模块基础 Repository
│   │   └── Migrations/
│   ├── Realtime/
│   │   ├── SCWebSocketClient.h/.m       连接、心跳、重连
│   │   ├── SCRealtimeEventRouter.h/.m    事件分发，不认识页面
│   │   ├── SCRealtimeEnvelope.h/.m       消息信封
│   │   └── SCReconnectPolicy.h/.m
│   ├── Image/SCImageLoader.h/.m
│   └── Analytics/SCEventTracker.h/.m
├── Shared/
│   ├── Components/
│   │   ├── SCMiniPlayerView.h/.m
│   │   ├── SCArtworkView.h/.m
│   │   ├── SCProgressSlider.h/.m
│   │   ├── SCTrackRowView.h/.m
│   │   └── SCUserAvatarView.h/.m
│   ├── Navigation/SCNavigationCoordinator.h/.m
│   ├── Presentation/SCToast、SCBottomSheet
│   └── Data/SCTrack、SCArtist、SCAlbum、SCPlaylist、SCUser
├── Modules/
│   ├── Home/
│   │   ├── SCHomeViewController
│   │   ├── SCHomeViewModel
│   │   ├── SCHomeService
│   │   └── Views/Cells/
│   ├── Search/
│   │   ├── SCSearchViewController、SCSearchResultViewController
│   │   ├── SCSearchViewModel、SCSearchService
│   │   └── Views/Cells/
│   ├── Library/
│   │   ├── SCLibraryViewController、SCLibraryListViewController
│   │   ├── SCLibraryService
│   │   └── Views/Cells/
│   ├── Player/
│   │   ├── SCFullPlayerViewController
│   │   ├── SCQueueViewController
│   │   ├── SCLyricsView
│   │   └── SCPlayerPresenter
│   ├── Playlist/
│   │   ├── SCPlaylistDetailViewController
│   │   ├── SCPlaylistEditorViewController
│   │   ├── SCCollaborativePlaylistService
│   │   └── Views/Cells/
│   ├── TogetherListen/
│   │   ├── SCTogetherRoomViewController
│   │   ├── SCTogetherRoomViewModel
│   │   ├── SCTogetherRoomService
│   │   ├── SCTogetherRealtimeAdapter
│   │   └── Views/Cells/
│   └── Profile/
│       ├── SCProfileViewController
│       ├── SCProfileService
│       └── Views/Cells/
├── Resources/
│   ├── Assets.xcassets
│   ├── Localizable.strings
│   └── Audio/Mock（仅开发测试）
└── Tests/
    ├── Unit/Player、Queue、Protocol、Repository、ViewModel
    ├── Integration/Network、WebSocket、TogetherRoom
    └── UI/Home、Search、Player、Playlist
```

## 3. 分层职责与依赖规则

- **Application** 只组装对象图和根导航，不调用具体 API。
- **Base** 提供通用 UI、错误、分页和协议；不得依赖 Modules。
- **Core** 提供网络、播放器、数据库和实时通信能力；不得导入业务 ViewController。
- **Shared** 放跨两个以上业务模块复用的模型和 UI；只依赖 Base/Core 的协议。
- **Modules** 负责业务流程。模块内部允许 Controller → ViewModel/Service → Core，但禁止 Home 直接导入 TogetherListen 的实现类。
- **Resources** 不包含业务逻辑。
- **Tests** 通过协议注入 fake client、fake player、fake clock 和 in-memory repository。

目录拆分的实际理由和主要依赖如下：

| 目录 | 代表类 | 依赖方向 | 单独划分原因 |
|---|---|---|---|
| Application | `SCAppRouter`、`SCEnvironment` | Base、Core、Modules 的组装接口 | 启动和环境切换只在一个组合根完成，业务模块可独立测试 |
| Base | `SCBaseViewController`、`SCError` | UIKit/Foundation | 避免每个模块重复实现加载态、错误态和主题常量 |
| Core/Networking | `SCNetworkClient`、`SCAuthInterceptor` | Foundation、Base 模型 | 统一鉴权、重试、解码和错误映射，页面不直接创建 `NSURLSession` |
| Core/Player | `SCMusicPlayerManager`、`SCPlayerEngine` | AVFoundation、Shared/Data | 播放生命周期跨页面且必须唯一，隔离 AVPlayer 细节 |
| Core/Persistence | `SCModelStore`、各 Repository | WCDB/SQLite | 将事务、迁移和本地缓存从业务流程中隔离 |
| Core/Realtime | `SCWebSocketClient`、`SCRealtimeEventRouter` | Foundation、Core 协议 | 只处理传输和事件路由，不知道一起听页面 |
| Shared | `SCTrack`、`SCArtworkView`、`SCNavigationCoordinator` | Base、Core 协议 | 只有被两个以上模块复用的模型、组件和导航契约才进入此层 |
| Modules | `SCHomeService`、`SCTogetherRoomService` | Shared、Core 接口 | 业务规则按边界聚合，模块间通过协议和导航意图通信 |
| Resources | Assets、strings、测试音频 | 无代码依赖 | 资源可替换、可本地化，避免散落在业务目录 |
| Tests | fake service、in-memory repository | 各层公开协议 | 验证状态机和边界条件，不依赖真实网络或音频服务 |

循环依赖的处理方式：模块只依赖 `Shared/Data` 的稳定模型和 `Core` 的协议；具体实现通过初始化注入。跨模块跳转统一调用 `SCNavigationCoordinator`，不用互相 `#import` Controller。WebSocket 事件先进入 `SCRealtimeEventRouter`，再由 TogetherListen adapter 转换为领域事件，Player 只接收 `SCPlaybackCommand`。

业务模块的依赖边界示例：Home 只依赖 `SCHomeServiceProtocol` 和导航意图；Search 只依赖 `SCSearchServiceProtocol`、`SCSearchHistoryRepositoryProtocol`；Playlist 只依赖 `SCPlaylistServiceProtocol`；TogetherListen 只依赖 `SCTogetherRoomServiceProtocol`、`SCRealtimeTransport` 和 `SCMusicPlayerControlling`。具体网络客户端、数据库实现和 AVPlayer 均在 Application 组合根注入。

## 4. 核心调用关系

```text
SCAppRouter
 └─ SCTabBarController
    ├─ SCHomeViewController → SCHomeViewModel → SCHomeService → SCNetworkClient
    ├─ SCSearchViewController → SCSearchService → SCNetworkClient
    ├─ SCLibraryViewController → Repository/LibraryService
    └─ SCProfileViewController → SCProfileService

SCMiniPlayerView / SCFullPlayerViewController
 └─ SCMusicPlayerManager
    ├─ SCPlaybackQueueManager
    ├─ SCPlayerEngine(AVPlayer)
    ├─ SCNowPlayingCoordinator
    └─ SCPlaybackClock

SCTogetherRoomService
 └─ SCTogetherRealtimeAdapter → SCWebSocketClient
                                  ↓
                         SCPlaybackCommand → SCMusicPlayerManager
```

`SCMusicPlayerManager` 是唯一对业务暴露的播放入口；`SCPlayerEngine` 不被页面直接访问。Mini Player 和全屏播放器订阅 `SCPlaybackSnapshot`，因此不会各自维护播放状态。

## 5. 为什么是模块化 MVC

简单 MVC 在 NLSpotify 规模较小时可用，但首页、播放、下载、缓存和实时房间继续增长后，ViewController 会同时承担 API、状态、导航和播放器操作。模块化 MVC 保留 UIKit 的可落地性，又把每个业务的 ViewController、ViewModel、Service、Cell 限制在边界内。它没有引入复杂的 Clean Architecture 或依赖注入容器，使用协议 + 构造注入即可在 Objective-C 中实现。

## 6. 接口约定

建议的关键协议：

```objc
@protocol SCMusicPlayerControlling <NSObject>
@property (nonatomic, readonly) SCPlaybackSnapshot *snapshot;
- (void)playQueue:(NSArray<SCTrack *> *)tracks index:(NSUInteger)index;
- (void)play; - (void)pause; - (void)skipNext; - (void)skipPrevious;
- (void)seekToProgress:(float)progress;
@end

@protocol SCRealtimeTransport <NSObject>
- (void)connectWithToken:(NSString *)token completion:(void (^)(NSError *error))completion;
- (void)sendEvent:(SCRealtimeEnvelope *)event completion:(void (^)(NSError *error))completion;
- (void)disconnect;
@end
```

Service 负责远程 API，不保存页面状态；Manager 负责跨页面、长生命周期状态；Repository 负责本地 CRUD 和事务；Delegate 只用于单向 UI 回调；Notification 只用于低耦合广播（登录失效、音频中断），不作为播放器主状态通道。
