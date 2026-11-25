# Phase 7.4C · Settings and privacy

## 页面与设置范围

Home 或 Library → Sidebar → Settings and privacy。抽屉收起后，设置页进入当前标签的导航栈，保留底部播放器和 TabBar。账号信息与侧栏、个人主页共享 SCUser，Edit profile 打开现有全屏编辑器。Log out、Change password 和 Clear cache 当前为带说明的不可用行。

| 页面 | 可查看或操作的内容 |
|---|---|
| Account | 昵称、头像、开发预览身份、未绑定邮箱、编辑个人资料 |
| Data Saver | 数据节省、蜂窝网络下载偏好 |
| Playback | Crossfade 0–12 秒、Gapless、Automix、Normalize volume、Volume level 与 Autoplay |
| Audio Quality | Wi-Fi、蜂窝、下载各有单独选项；下载音质从 Low 开始 |
| Storage | 安装包文件大小、音乐缓存、下载、其他已用空间、卷可用空间 |
| Notifications | 音乐推荐、新发行、歌单更新、产品消息 |
| Privacy | 私密会话、收听活动、资料可见性 |
| Appearance | 当前主题 Dark、语言 English |
| About | 现有 Logo、应用名称、Bundle 版本与构建号、学习项目说明、许可证全文 |

设置用 SCSettingsItem 描述行类型、文字、图标和用途。SCSettingsCell 在初始化时绑定开关和滑块事件，复用时按行类型配置控件。选择结果由 SCSettingsPreviewState 存在进程内，页面返回时重新读取。播放引擎、推送和服务端隐私均未接入。

SCStorageUsageView 在后台读取文件系统卷容量与剩余空间，统计当前安装包内普通文件的逻辑字节数。安装包不包含 Documents 等用户数据；彩条以整卷为分母，零大小分类保留文字说明。读取失败显示 Unavailable，总容量缺失或为零时不绘制比例。音乐缓存和下载显示 0 B，页面没有删除文件的操作。

## 文件与资源

- 新增 Settings/Models 下 SCSettingsItem、SCSettingsPreviewState 的 .h/.m。
- 新增 Settings/Views 下 SCSettingsView、SCSettingsCell、SCStorageUsageView 的 .h/.m。
- 新增 Settings/ViewControllers 下 SCSettingsViewController 的 .h/.m。各页面使用同一个页面控制器按设置描述渲染。
- 新增 Settings/Licenses 下 AFNetworking、LookinServer、Masonry、YYModel 对应的四份许可证文本，逐字复制自当前 Pods 中各自的 LICENSE。LookinServer 的 CocoaPods acknowledgements 标为 GPL-3.0，而该目录的 LICENSE 正文为 MIT，因此页面展示随源码提供的正文。
- 修改 Sidebar/ViewControllers/SCRootContainerViewController.m、Spotify.xcodeproj/project.pbxproj 及开发路线图。新增本报告和设置界面的模拟器截图。

## 人工验收

1. 从 Library 播放一首歌曲后进入设置。修改三类音质并返回，检查每类保留自己的值。拖动 Crossfade 到两端，检查 Off 与 12s。
2. 在 Account 编辑昵称或头像。确认返回后 Account、设置首页和侧栏同步更新。检查邮箱和身份文案。
3. 在小屏、横屏和较大字号下检查长标题、开关、许可证正文、底部 Log out 和 MiniPlayer 的间距。
4. 在真机复核存储容量及单位。退出设置后确认原标签、曲目、暂停状态和队列，重启应用后检查临时设置恢复默认。

## 实测结果

2026-11-24，使用 Spotify.xcworkspace、Spotify scheme、Debug 和通用 iOS Simulator 目标构建成功。四份已打包许可证均与对应 Pods 源文件逐字节一致。改动文件通过 clang-format dry-run 和工程语法检查；手写布局扫描仅命中存储条 CALayer 随 bounds 更新尺寸。

使用独立测试应用在 iPhone 17 Pro、iOS 26.3 驱动相同业务源码。最终运行中九个设置页均可进入并返回，Account 可打开既有编辑器。滑块设为 7 秒、Gapless 开关切换成功；Wi-Fi 选 Very High 后，蜂窝和下载分别保持 Automatic、Normal。返回重进 Playback 后滑块仍为 7 秒。许可证列表有四项，可进入正文。退出设置后原 Home 标签、歌曲及播放状态保留。测试日志未出现约束冲突。首两轮自动检查在导航动画尚未完成时触发下一次点击，最终逐次等待 UIKit 转场完成后复测通过。

已查看[设置首页](phase-7.4c/Settings.png)、[播放设置](phase-7.4c/Playback.png)和[存储空间](phase-7.4c/Storage.png)的模拟器截图。存储截图反映测试应用包和模拟器卷的实测值。当前测试覆盖一种设备与系统组合，真机容量、小屏和大字号仍需人工验收。
