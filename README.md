# openharmonyUI

一个基于 HarmonyOS / ArkTS 的智能家居设备控制面板示例项目。

## 功能

- 智能家居设备列表展示
- 设备开关与播放状态切换
- 下拉刷新设备状态
- 手机 / 平板自适应布局
- 桌面卡片（Form）联动展示
- 基于本地 mock 数据的设备状态持久化

## 运行方式

1. 使用 DevEco Studio 打开本项目。
2. 确认本地已安装 HarmonyOS SDK `6.0.2`。
3. 选择设备或模拟器后运行 `entry` 模块。

## 目录

- `entry/src/main/ets/pages/`：主页面
- `entry/src/main/ets/model/`：数据模型
- `entry/src/main/ets/mock/`：mock 数据仓库
- `entry/src/main/ets/store/`：设备状态与桌面卡片同步逻辑
- `entry/src/main/ets/form/`：桌面卡片页面
- `entry/src/main/resources/rawfile/`：界面图片与图标资源

## 说明

- 当前设备数据主要来自 mock 数据，适合演示 UI、交互和卡片联动。
- 仓库已支持 GitHub Copilot PR review，可通过 `.github/copilot-instructions.md` 提供审查上下文。
- 使用DevEco Studio和其他AI工具（DevEco CodeGenie/Code Arkts/Trae等）进行代码开发
