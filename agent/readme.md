# Agent

`agent/` 是 personal-configs 中面向 Codex 的能力配置入口，用来集中维护用户级指令、可复用 Skills 和部署逻辑。

## 功能

- 通过 `AGENTS.md` 为 Codex 提供用户习惯、工作目录和开发流程等通用上下文。
- 通过 `skills/` 按场景组织可独立触发的专业能力，避免把大量细节塞进全局指令。
- 通过显式 target 将配置自动同步到 `~/.codex/`，不依赖隐式目录扫描，也不影响 Codex 自带或其他来源的 Skills。
- 当前只部署到 Codex，后续如需支持其他 Agent，可以增加独立 target。

## Skills

- [`ai-sdk`](skills/ai-sdk)：用于 Vercel AI SDK 的问答和开发，覆盖文本生成、流式输出、工具调用、Agent、RAG、结构化输出、嵌入及 UI hooks；实现前会优先核对项目已安装版本附带的文档和源码。该 Skill 来自 Vercel 官方仓库的 [`vercel/ai/skills/use-ai-sdk`](https://github.com/vercel/ai/tree/main/skills/use-ai-sdk)，并保留 Apache-2.0 许可证。
- [`gh-proxy`](skills/gh-proxy)：诊断国内网络下公共开发资源的访问问题，按“直连 → 本地 Mihomo/Clash → 公共加速服务”的顺序选择方案，覆盖 GitHub、公共容器镜像、SourceForge、cdnjs 和 OpenSheet 等资源。
- [`lark-meeting-records`](skills/lark-meeting-records)：通过 `lark-cli` 只读获取飞书/Lark 的会议 AI 摘要、逐字稿、Minutes 和 Note，处理不同链接类型、资料关联及最小权限授权流程。
- [`ui-vercel`](skills/ui-vercel)：用于设计和实现克制、精确、产品导向的 Vercel 风格界面，提供 9 类页面场景、组件契约、设计规范、截图和可运行的 TypeScript 参考实现，同时支持迁移到 Vue、React 或原生 HTML/CSS。[在线预览](https://vercel-ui-demo.qiudeng.workers.dev)

## 目录

```text
agent/
├── AGENTS.md
├── skills/
│   ├── ai-sdk/
│   ├── gh-proxy/
│   ├── lark-meeting-records/
│   └── ui-vercel/
└── targets/
    └── codex.sh
```

`AGENTS.md` 是 Codex 的用户级指令。`skills/` 中的每个子目录代表一个独立 Skill。
`targets/` 保存面向不同 Agent 的部署脚本；当前只有 Codex target。

## 同步流程

执行 `chezmoi apply` 或 `chezmoi update` 时，chezmoi 会在完成普通配置同步后运行：

```text
.chezmoiscripts/run_after_90-dispatch.sh.tmpl
```

`.chezmoiscripts` 中的 dispatcher 只负责生命周期调度，并显式调用 `agent/targets/codex.sh`，不会自动扫描或执行其他脚本。Codex target 执行以下同步：

```text
agent/AGENTS.md  → ~/.codex/AGENTS.md
agent/skills/*   → ~/.codex/skills/*
```

Skills 同步只更新由 personal-configs 管理的同名目录，不影响 Codex 自带的 `.system` 或其他 Skills。

`agent/` 已加入 `.chezmoiignore`，因此不会被直接创建为 `~/agent`。
