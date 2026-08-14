# Agent

Agent 配置的唯一来源，当前只组装到 Codex，包含通用指令和 Skills。

## 目录

```text
agent/
├── AGENTS.md
├── skills/
│   └── gh-proxy/
└── targets/
    └── codex.sh
```

`AGENTS.md` 是 Codex 的用户级指令。`skills/` 中的每个子目录代表一个独立 Skill。

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

Skills 同步只更新同名目录，不影响 Codex 自带的 `.system` 或其他 Skills。

`agent/` 已加入 `.chezmoiignore`，因此不会被直接创建为 `~/agent`。
