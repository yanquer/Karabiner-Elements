# 持久记忆

## 2026-06-29 简体中文界面本地化

- 本次新增 `zh-Hans` 简体中文界面支持，范围限定在 `SettingsWindow`、`EventViewer`、`Menu`、`MultitouchExtension` 的固定 UI 文案。
- 不翻译用户数据、设备名、配置名、日志、JSON 错误、第三方 complex modifications 资产标题/描述、`simple_modifications.json` 规则标签。
- 已将不方便当前翻译的部分纳入后续计划：规则标签本地化、complex modifications 多语言字段设计、core/service 系统通知消息、日志/错误提示中文包装、繁体中文 `zh-Hant`。
- 关键动态标题需要显式本地化，例如侧边栏 title、Setup title、`NSAlert` 按钮和共享按钮标题；不能只依赖 `Text("...")` 字面量自动本地化。
