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

## 手动安装工具集

工具安装可能调用系统包管理器并请求 `sudo` 权限，因此不会随
`chezmoi apply` 或 `chezmoi update` 自动执行。需要安装或更新当前系统的
工具集时，在仓库根目录显式运行：

```bash
sh tools/main.sh
```

## Domain 文档

- [Git](dot_config/git/readme.md)
- [Agent](agent/readme.md)
- [Tools](tools/readme.md)
