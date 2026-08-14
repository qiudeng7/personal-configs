# Git

为所有 Git 仓库启用用户级 `commit-msg` Hook，仅约束提交信息首行。

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

## 文件

- [`config`](config)：配置用户级 `core.hooksPath`
- [`hooks/executable_commit-msg`](hooks/executable_commit-msg)：校验提交信息首行

Hook 使用 Python 3 运行。本地校验可以被 `git commit --no-verify` 或仓库级 `core.hooksPath` 覆盖绕过。
