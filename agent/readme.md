# Agent

Agent 配置的唯一来源，当前包含通用指令和 Skills。

## 目录

```text
agent/
├── AGENTS.md
└── skills/
    └── gh-proxy/
```

`AGENTS.md` 暂时只保存在仓库中，不自动部署。`skills/` 中的每个子目录代表一个独立 Skill。

## 同步流程

执行 `chezmoi apply` 或 `chezmoi update` 时，chezmoi 会在完成普通配置同步后运行：

```text
.chezmoiscripts/run_after_90-agent-skills.sh.tmpl
```

该脚本把 `agent/skills/*` 分别同步到 `~/.agents/skills/*`。它只更新同名 Skill，不影响目标目录中的其他 Skills。

`agent/` 已加入 `.chezmoiignore`，因此不会被直接创建为 `~/agent`。
