# personal-configs

使用 [chezmoi](https://www.chezmoi.io/) 管理的个人配置。

## 当前配置

为所有 Git 仓库启用用户级 `commit-msg` Hook，仅约束提交信息首行：

```text
type(domain): 中文消息
```

- `type`：只能包含英文字母和连字符（`-`）
- `domain`：只能包含英文字母、连字符（`-`）和斜杠（`/`）
- 消息：必须至少包含一个中文字符
- 第二行及后续内容不受约束

示例：

```text
feat(git-hooks): 添加提交信息校验
build-tools(api/auth-v2): 更新登录服务构建流程
```

Hook 使用 Python 3 运行。

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
