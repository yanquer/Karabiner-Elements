# 持久记忆

## 2026-06-29 简体中文界面本地化

- 本次新增 `zh-Hans` 简体中文界面支持，范围限定在 `SettingsWindow`、`EventViewer`、`Menu`、`MultitouchExtension` 的固定 UI 文案。
- 不翻译用户数据、设备名、配置名、日志、JSON 错误、第三方 complex modifications 资产标题/描述、`simple_modifications.json` 规则标签。
- 已将不方便当前翻译的部分纳入后续计划：规则标签本地化、complex modifications 多语言字段设计、core/service 系统通知消息、日志/错误提示中文包装、繁体中文 `zh-Hant`。
- 关键动态标题需要显式本地化，例如侧边栏 title、Setup title、`NSAlert` 按钮和共享按钮标题；不能只依赖 `Text("...")` 字面量自动本地化。

## 2026-06-29 自编译打包

- 本次目标是生成手动安装用 `Karabiner-Elements-16.0.20.dmg`，不执行 `make install`，不卸载 Homebrew cask，不直接覆盖 `/Applications`。
- 本机只有 `Apple Development` 应用签名证书，可用于签名 app/bin；缺少 installer signing identity，所以 `productsign` 无法给 flat pkg 签名。
- Xcode 16.4 / Swift 6 构建时修复了两个工具链兼容问题：`MultitouchExtension` 避免 async notification 的 non-Sendable `Notification?`，`Updater` 移除需要实验特性的 `isolated deinit`。
- GitHub 直连拉取 Sparkle 依赖会卡住；打包时需要带 `HTTP_PROXY=127.0.0.1:7890 HTTPS_PROXY=127.0.0.1:7890`。
- `49F205BD536060C3B4389CC8D7600DD037B8F306` 等本机 Apple Development 身份会被 `spctl` 判为 `CSSMERR_TP_CERT_REVOKED`，会触发 Gatekeeper “包含恶意软件”提示；本机临时安装包改用 ad-hoc 重签 app/bin。
