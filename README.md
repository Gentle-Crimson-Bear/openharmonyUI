# openharmonyUI

## GitHub Copilot PR Review

这个仓库改成使用 GitHub 官方的 Copilot code review，不再使用自建的 GitHub Actions review bot。

仓库级指引文件在：

- `.github/copilot-instructions.md`

这个文件会告诉 Copilot 在这个 HarmonyOS / ArkTS 项目里应该优先关注哪些问题。

### 手动触发 Review

在 PR 页面打开 `Reviewers`，选择 `Copilot` 即可请求官方 review。

### 自动触发 Review

如果你有 Copilot Pro，可以在 GitHub 仓库里开启自动 review。常见路径是：

`Settings -> Rules -> Rulesets -> New branch ruleset`

在规则里开启 `Automatically request Copilot code review`。如果需要，也可以同时打开：

- `Review new pushes`
- `Review draft pull requests`

### 说明

这个方案不需要你自己提供 OpenAI API key，但需要你的 GitHub 账号或所属组织具备 GitHub Copilot code review 能力。
