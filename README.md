# personal-configs

使用 [chezmoi](https://www.chezmoi.io/) 管理、按 domain 组织的个人配置仓库。

## 使用

安装 chezmoi 后执行：

```bash
chezmoi init --apply qiudeng7/personal-configs
```

拉取并应用后续更新：

```bash
chezmoi update
```

查看将要应用的变更：

```bash
chezmoi diff
```

## Domain 文档

- [Git](dot_config/git/readme.md)
- [Agent](agent/readme.md)
