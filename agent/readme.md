# Agent

Agent 配置的唯一来源，当前只组装到 Codex，包含通用指令和 Skills。

## 目录

```text
agent/
├── AGENTS.md
├── sync-codex.sh
└── skills/
    └── gh-proxy/
```

`AGENTS.md` 是 Codex 的用户级指令。`skills/` 中的每个子目录代表一个独立 Skill。

## 同步流程

执行 `chezmoi apply` 或 `chezmoi update` 时，chezmoi 会在完成普通配置同步后运行：

```text
.chezmoiscripts/run_after_90-codex.sh.tmpl
```

`.chezmoiscripts` 中的文件只是 chezmoi 生命周期入口，实际同步逻辑与 Agent source 一起位于 `agent/sync-codex.sh`。它执行以下同步：

```text
agent/AGENTS.md  → ~/.codex/AGENTS.md
agent/skills/*   → ~/.codex/skills/*
```

Skills 同步只更新同名目录，不影响 Codex 自带的 `.system` 或其他 Skills。

`agent/` 已加入 `.chezmoiignore`，因此不会被直接创建为 `~/agent`。
