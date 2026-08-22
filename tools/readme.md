# Tools

`tools/` 管理个人常用命令行工具的用户级二进制安装与更新。它面向 chezmoi 同步流程：执行 `chezmoi apply` 或 `chezmoi update` 后，由 `.chezmoiscripts` 调用统一入口 `tools/installer.sh`。

## 职责范围

`tools/` 只负责让工具的二进制文件存在并尽量保持最新：

- 下载、校验、安装或替换用户级二进制文件
- 默认安装到 `~/.local/bin`，可由工具脚本按需支持环境变量覆盖
- 以幂等方式运行：已是最新版本时不重复安装
- 尽量只依赖基础命令，如 `sh`、`uname`、`curl`、`tar`、`chmod`、`mkdir`、`mv`

`tools/` 明确不负责：

- 修改 `zshrc`、`bashrc`、profile 或 PATH
- 创建或管理 `systemd`、launchd、cron 等服务
- 管理工具自身的登录态、配置文件、插件、skills、缓存或运行时状态
- 安装语言运行时包管理器中的全局包，除非该工具本身就是目标二进制
- 接管 Homebrew、apt、dnf、pacman、npm、pip 等系统或语言包管理器

如果某个工具需要 shell 初始化、服务配置、登录授权或项目级配置，应放到对应 domain 的文档或脚本里，不放在 `tools/` installer 中。

## 目录约束

```text
tools/
├── installer.sh
├── readme.md
└── <tool>/
    └── install.sh
```

`installer.sh` 是统一入口，负责检查基础命令并按目录顺序调用每个工具的 `install.sh`。

每个 `tools/<tool>/install.sh` 必须满足：

- 可由 POSIX `sh` 执行
- 接收两个参数：`tools_dir` 和 `home_dir`
- 不依赖当前工作目录
- 输出简洁状态信息
- 失败时返回非零退出码
- 不修改仓库文件

## 当前工具

- `lark-cli`：从 `larksuite/cli` GitHub release 下载最新官方二进制，不使用 npm，不安装官方 skills。
