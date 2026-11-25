# Phase 7.5 · 同步歌词

## 入口与数据

播放曲目，点 MiniPlayer 展开全屏播放器，选择右上角更多 → Lyrics。现有封面、进度和传输控制占用主要阅读空间，沿用菜单入口。歌词页使用实际本地封面对应的深色渐变、动态行高、原文与可切换译文，以及原有 SCPlayerProgressView。分享内容为歌曲名和歌手名。

| 本地歌曲 | 覆盖场景 |
|---|---|
| Somewhere in Blue | 12 行原创英语歌词、部分中文翻译、长句、毫秒时间 |
| Last Train Home | 中文、同一行两个时间戳、乱序、无效秒数 |
| Stay a Little Longer | 无时间戳的纯文本，可手动阅读 |
| A Softer World | 仅有非法时间戳，显示读取错误状态 |
| Coastline 等其余曲目 | 无资源，显示无歌词状态 |

## 实现与文件

- 新增 Player/Lyrics/Models/SCLyricsModel.h/.m，包含歌曲信息、类型、元数据、歌词行和译文。
- 新增 Player/Lyrics/Services 下 SCLRCParser、SCLyricsTimeline、SCLyricsProvider 三组 .h/.m。Provider 以曲目唯一 ID 在后台读取并解析 UTF-8 资源，主线程按请求序号接收，避免快速切歌时使用旧结果。
- LRC 支持 LF/CRLF、整秒及小数秒、多时间戳、元数据与毫秒 offset。正 offset 提前显示，负值延后，负起点归零。先收集再排序，同一原始时间保留最后出现的有效文本，归零后重合的时间保留原时间较晚者。翻译按各自 offset 调整后的毫秒键精确匹配。
- 时间轴使用二分查找最后一个起点小于等于当前时间的歌词，复杂度 O(log n)。空列表及第一句前返回 NSNotFound。
- 新增 Player/Lyrics/Views/SCLyricsView.h/.m 与 ViewControllers/SCLyricsViewController.h/.m。仅切歌、加载完成或切换翻译时重载列表。进度变化仅在索引改变时更新可见行。用户主动拖动即暂停跟随，减速结束后继续保持手动浏览，点返回当前句或点歌词可恢复。纯文本无定时高亮或点击跳转。
- 修改 SCPlaybackManager.h/.m、SCPlayerViewController.m 和 Xcode 工程文件。原管理器只有主动 seek 才改变进度，现在由同一管理器在播放期间推进模拟时钟，暂停时停表。普通进度通知只更新进度订阅方，避免列表和队列反复刷新。自动到达曲尾时按队列和当前模式处理。
- 新增 5 个本地 .lrc 资源、Tests/Lyrics/SCLyricsTests.m、Tests/Lyrics/run-tests.sh、此报告与[歌词截图](phase-7.5/Lyrics.png)。路线图保留 7.2、7.3、7.4D。

## 验证记录

2026-11-24，Spotify.xcworkspace 的 Spotify scheme，Debug，通用 iOS Simulator，编译成功。现有 Pods 部署目标警告仍存在。Foundation 解析器与时间轴使用 macOS XCTest 运行，项目根目录执行 Tests/Lyrics/run-tests.sh；三个测试方法全部通过。测试含 offset 正负值、时间精度、多标签、重复、排序、异常、中文、翻译、空文本、二分边界及非单调跳转。

iPhone 17 Pro、iOS 26.3 的隔离测试应用使用相同业务源码和歌词资源，执行 11 项 UIKit 与共享状态检查。验证页面打开、进度推进、暂停时点击第三行精确跳至 9.125 秒、手动浏览、恢复跟随、翻译切换、快速切歌、纯文本、异常与空状态、单曲循环，以及关闭后的播放与队列。测试直接触发全屏播放器的歌词动作和列表拖动委托，实际手势与更多菜单点击留待人工验收。

## 人工验收

1. 从 Blue Reverie 打开 Somewhere in Blue。观察播放、暂停、进度条和中英文切换，再关闭歌词页核对播放器时间。
2. 拖动列表并松手，跨越几行后确认仍停在阅读位置；点 Return to current lyric，再连续拖动进度条，检查滚动手感。
3. 在歌词页暂停后点长句，核对仍为暂停；用单曲循环从末尾回到开头，检查第一句重新高亮。
4. 对照样例表检查纯文本、异常与无歌词状态。在小屏和大字号下检查换行、底部时间与分享入口。当前只测本地模拟时间，尚未验证真实音频同步。
