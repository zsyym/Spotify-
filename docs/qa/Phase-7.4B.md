# Phase 7.4B · 个人主页与编辑资料

## 实现范围

Home 和 Library 的侧栏完成关闭动画后，在当前标签的导航栈打开 Profile。个人主页使用一个 UICollectionView，头部的 backing layer 是随视图尺寸变化的 CAGradientLayer。滚动时以同一进度更新导航背景和昵称透明度，返回按钮固定在安全区。

Followers 在本地预览中为零，Following 读取 SCLibraryStore。最近播放歌手区域使用标注为 Preview artist 的本地样例，可进入已有歌手详情。当前没有公开歌单归属数据，因此展示空状态。分享内容为昵称。

全屏编辑表单在打开时复制昵称与头像。昵称去除首尾空白后按组合字符计数，允许 1 至 30 个字符，中文和组合 Emoji 均可使用。保存发布 SCProfileDidChange；重新打开的侧栏直接读取 SCUser.current。资料只保存在内存中。PHPicker 读取单张图片的文件表示，在提供者回调中用 ImageIO 按方向解码并缩小到最长边 512 像素，主线程显示圆形等比裁剪预览。取消、加载失败和过期回调保留原资料。

## 实际检查

2026-11-24，Spotify.xcworkspace，Spotify scheme，Debug，generic iOS Simulator，关闭签名。Xcode 编译成功。项目 clang-format dry-run、工程语法、diff 空白和改动文件布局 API 扫描通过。

iPhone 17 Pro、iOS 26.3。在独立测试应用中运行相同业务源文件，驱动 UIKit 控件、实际导航栈和本地模拟播放器。检查结果如下。

| 场景 | 结果 |
|---|---|
| Home、Library 分别进入侧栏并打开 Profile | 均打开当前标签下的个人主页 |
| Edit profile 初始状态、纯空白和 31 字符输入 | Save 禁用 |
| 输入带首尾空白的中文与组合 Emoji | 编辑期间共享昵称不变，保存后昵称正确去除空白 |
| 使用本地图片作为头像草稿，再保存 | 当前会话模型接收到头像 |
| 清除头像草稿后点击 Cancel | 显示放弃确认，共享头像保持原值 |
| 保留编辑并保存默认头像 | 当前头像清空，显示昵称首字 |
| 退出主页后核对两个头像入口 | Home 和 Library 均读取新昵称 |
| 歌手卡片、切换入口、回到主页 | 进入正确的歌手详情，当前播放曲目保持一致 |

头像状态测试在草稿层注入图片，未驱动系统相册。取消测试覆盖确认框出现及保留编辑。无公开歌单可点击，未执行从个人主页进入歌单的端到端测试。模拟器记录了系统 Emoji 字体回退提示。

已查看[个人主页截图](phase-7.4b/Profile.png)和[编辑页截图](phase-7.4b/Edit.png)。主页保留 MiniPlayer 和 TabBar，编辑页全屏显示顶部操作与表单。

## 人工验收

1. 从两个标签重复进入 Profile。滚动到 Following，观察导航栏渐变、返回按钮、末行与 MiniPlayer 的间距。
2. 选择横图、竖图或大图，检查圆形裁剪。分别测试取消系统选择、恢复默认、放弃修改和保存；回到侧栏与两个标签核对头像。
3. 用中文输入法、Emoji 和长昵称检查输入、截断、键盘 Return 与 Save 的可达性，复查小屏与大字号。
4. 测试分享、关注歌手、切换页面后的暂停状态与完整队列。重启确认资料回到开发预览值。

## 文件

- 新增 Profile/Views 下 SCProfileAvatar、SCProfileHeader、SCProfileView、SCEditProfileView 的 .h/.m。
- 新增 Profile/ViewControllers 下 SCProfileViewController、SCEditProfileViewController 的 .h/.m。
- 修改 Common/Models/SCUser.h/.m、Home/Views/SCHomeHeaderView.m、Library/Views/SCLibraryView.m、Sidebar/Views/SCSidebarItemCell.m、Sidebar/ViewControllers/SCRootContainerViewController.m 及 Spotify.xcodeproj/project.pbxproj。
- 更新开发路线图，新增本 QA 记录及两张模拟器截图。
