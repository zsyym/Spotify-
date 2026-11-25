# Phase 7.1 · 专辑与歌手详情验收记录

2026-11-24。原有专辑和歌手详情是占位页，首页最近播放的专辑卡片显示提示。Search 和 Library 已有统一路由，音乐库和播放器也已有共享实例。此次补全详情页并复用这些入口。工作区此前没有可对照的 docs/qa 审查报告。

## 数据口径

本地目录有 6 张专辑、6 位虚构歌手和 24 首曲目。曲目靠稳定专辑 ID 和歌手对象关联作品，专辑保留有序曲目数组。相关歌手使用 ID，歌手页按目录顺序展示本地 Popular。示例发行年份仅属于虚构测试数据。详情页省略缺失的完整发行日期、版权和听众数。没有 Single 或 EP 时不创建相应分区。

## 编译与运行检查

使用 Spotify.xcworkspace、Spotify scheme、Debug 和 iOS Simulator SDK 编译成功。构建使用 CODE_SIGNING_ALLOWED=NO，Pods 工程有既有的 deployment target 警告。改动范围的 Objective-C 文件通过项目 clang-format 检查，Xcode 工程文件通过 plutil 检查。

模拟器为 iPhone 17 Pro，iOS 26.3。交互检查使用相同业务源文件和隔离的本地用户数据，在 UIKit 中触发控件与列表选择，并读取实际页面、导航栈和共享服务状态。以下记录可用于人工复测。

| 路径或场景 | 实测结果 |
|---|---|
| Home → Recently Played → Blue Reverie | 进入对应专辑，显示标题、Album、年份和 4 首编号曲目。点击第 2 首 Window Seat 后，队列与该专辑完整曲目顺序一致，从第 2 首开始。 |
| 专辑操作区 | 当前来源的播放按钮可暂停，随机按钮切换到共享随机模式，收藏按钮改变音乐库状态。 |
| 专辑 → Luna Park → Popular | 歌手页展示 7 个有内容的分区。选择热门歌曲后队列和来源切换至该歌手，关注按钮改变同一个音乐库中的状态。 |
| 歌手 → 发行作品、Fans Also Like | 进入对应专辑和相关歌手；对同一发行作品连续触发两次导航，只压入一次。 |
| Search、Your Library | 分别通过搜索结果以及音乐库的专辑和歌手筛选，打开两种详情。 |
| MiniPlayer | 在验证位置，详情列表底边位于 MiniPlayer 上方。点击 MiniPlayer 能展开全屏播放器。 |
| 边界数据 | 用空专辑、单曲目专辑、缺少作品和热门歌曲的歌手构建详情，检查对应分区与曲目数量。 |
| 视觉回归 | 首轮截图发现专辑标题和年份受压缩、歌手头图渐变与相关头像圆角尺寸有误。修正后再次运行，检查文字高度、渐变尺寸和头像圆角，并复看下列截图。 |

## 最终模拟器截图

- [专辑首屏 · 标题、年份、选中曲目与 MiniPlayer](phase-7.1/Album.png)
- [歌手首屏 · 渐变头图、Following 和 Popular](phase-7.1/Artist.png)
- [歌手下半页 · 滚动标题、相关歌手与虚构资料说明](phase-7.1/ArtistCatalog.png)

## 人工验收

1. 在首页打开 Blue Reverie，点第 2 首歌，展开 MiniPlayer 核对来源，关闭后上下拖动详情，观察标题渐显、滚动手感和底部末行。
2. 进入 Luna Park，比较 Follow 与 Following 两种状态。切换 Library 检查新增，再取消收藏或关注，确认条目移除。退出并重开应用，检查持久化结果。
3. 在小屏设备和大字号设置下检查标题截断、按钮间距和底部可达性。在 iOS 15 运行时复查兼容性。本轮覆盖 iOS 26.3 的单一设备配置。
4. 更多操作目前沿用现有入口，下载显示本地预览提示。统一操作 Sheet、真实播放历史、真实音频与下载属于后续阶段。

## 本阶段文件清单

下表中的 .h/.m 表示同名头文件与实现文件各一份。路径相对仓库根目录。

| 类型 | 目录 | 文件 |
|---|---|---|
| 新增 | Spotify/Common/ViewControllers | SCCatalogDetailViewController.h/.m |
| 新增 | Spotify/Common/Views | SCCatalogDetailView.h/.m、SCNumberedTrackCell.h/.m、SCReleaseControlsCell.h/.m |
| 修改 | Spotify/Album | Models/SCAlbumDetailModel.h/.m、Views/SCAlbumDetailView.h/.m、Views/SCAlbumHeaderView.h/.m、ViewControllers/SCAlbumDetailViewController.h/.m |
| 修改 | Spotify/Artist | Models/SCArtistDetailModel.h/.m、Views/SCArtistDetailView.h/.m、Views/SCArtistHeaderView.h/.m、ViewControllers/SCArtistDetailViewController.h/.m |
| 修改 | Spotify/Common/Models | SCTrack.h、SCAlbum.h/.m、SCArtist.h/.m、SCLocalMusicCatalog.m |
| 修改 | Spotify/Common | ViewControllers/SCMusicNavigation.m、Views/SCMusicItemCell.m |
| 修改 | Spotify/Home/ViewControllers | SCHomeViewController.m |
| 修改 | Spotify/Player/Services | SCPlaybackManager.h/.m |
| 修改 | Spotify/Spotify.xcodeproj | project.pbxproj |
| 修改 | 仓库根目录 | SpotifyClone_Development_Roadmap.md |
| 新增 | docs/qa | Phase-7.1.md、phase-7.1/Album.png、phase-7.1/Artist.png、phase-7.1/ArtistCatalog.png |
