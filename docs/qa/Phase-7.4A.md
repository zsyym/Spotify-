# Phase 7.4A · 侧栏验收记录

2026-11-24。开发预览登录入口呈现 SCRootContainerViewController，内部保留同一个 SCMainTabBarController。侧栏打开时添加 child controller，关闭完成后移除。Search 当前没有头像入口。SCUser 仍是空占位，抽屉显示本地开发预览身份。仓库根目录没有 README.md。

## 实测

Spotify.xcworkspace 的 Spotify scheme 在 Debug、通用 iOS Simulator 目标下编译成功。Pods 有既有的旧部署版本警告。改动的 Objective-C 文件通过 clang-format 检查，未发现原生约束创建或固定 frame 布局。

iPhone 17 Pro 模拟器使用单独的测试应用驱动同一套业务代码。检查覆盖 Home 连续触发头像只出现一个抽屉、五行菜单、背景禁用、遮罩关闭保留标签、Library 打开、关闭后显示设置预览提示，以及操作后播放曲目、队列、播放状态和当前标签。手势手感与视觉待人工验收。

## 人工检查

1. 从 Login 开发预览进入 Home，播放一首本地测试歌曲。快速点两次头像，观察遮罩是否覆盖 TabBar 和 MiniPlayer。
2. 慢速向左短拖并松手，抽屉应回到原位。超过约一半或快速向左甩动应关闭。点遮罩也应关闭。
3. 切到 Library，打开并关闭侧栏，确认仍停在 Library，播放器可以正常展开，队列保持一致。
4. 选择 Settings and privacy 或 View profile，确认抽屉先关闭，再显示预览提示。Add account 返回原登录界面。
5. 在小屏、横屏和开启减弱动态效果时检查抽屉宽度、菜单滚动与动画。

## 文件

- 新增 Sidebar 模块下 SCRootContainerViewController、SCSidebarViewController、SCSidebarItemCell 的头文件与实现。
- 修改 SCLoginViewController.m、SCHomeViewController.m、SCHomeHeaderView.m、SCLibraryView.h/.m、SCLibraryViewController.m 和 Xcode 工程引用。
- 更新开发路线图，新增本验收记录。
