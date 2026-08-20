# Git

为所有 Git 仓库启用用户级 Hooks，统一提交信息格式并阻止常见垃圾文件进入仓库。

## 提交信息格式

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
build-tools(api/auth-service): 更新登录服务构建流程
```

## 垃圾文件检查

`pre-commit` 只检查暂存区中即将提交的文件，并阻止以下高置信度垃圾文件：

- macOS 和 Windows 元数据，如 `.DS_Store`、`._*`、`__MACOSX`、`Thumbs.db` 和 `Desktop.ini`
- Vim、Emacs 等编辑器生成的交换、自动保存和备份文件
- 合并或补丁生成的 `*.orig`、`*.rej` 残留文件

构建产物、IDE 配置和依赖目录不属于全局规则，由各项目自行决定是否提交。

## 文件

- [`config`](config)：配置用户级 `core.hooksPath`
- [`hooks/executable_commit-msg`](hooks/executable_commit-msg)：校验提交信息首行
- [`hooks/executable_pre-commit`](hooks/executable_pre-commit)：阻止暂存区中的常见垃圾文件

Hooks 使用 Python 3 运行。本地校验可以被 `git commit --no-verify` 或仓库级 `core.hooksPath` 覆盖绕过。
