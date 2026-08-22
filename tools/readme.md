# Tools

`tools/` 管理个人常用命令行工具的用户级二进制安装与更新。它面向 chezmoi 同步流程：执行 `chezmoi apply` 或 `chezmoi update` 后，由 `.chezmoiscripts` 调用统一入口 `tools/installer.sh`。

## 职责范围

`tools/` 只负责让工具的二进制文件存在并尽量保持最新：

- 下载、校验、安装或替换用户级二进制文件
- 默认安装到 `~/.local/bin`，可由工具脚本按需支持环境变量覆盖
- 以幂等方式运行：已是最新版本时不重复安装
- 只依赖本文定义的 Tools Runtime Baseline 和工具条目显式声明的附加能力

`tools/` 明确不负责：

- 修改 `zshrc`、`bashrc`、profile 或 PATH
- 创建或管理 `systemd`、launchd、cron 等服务
- 管理工具自身的登录态、配置文件、插件、skills、缓存或运行时状态
- 安装语言运行时包管理器中的全局包，除非该工具本身就是目标二进制
- 接管 Homebrew、apt、dnf、pacman、npm、pip 等系统或语言包管理器

如果某个工具需要 shell 初始化、服务配置、登录授权或项目级配置，应放到对应 domain 的文档或脚本里，不放在 `tools/` installer 中。

## Runtime Baseline

Tools Runtime Baseline v1 是 `tools/` installer 可以假设存在的最小运行环境。当前只支持 macOS 和 Linux，不支持 Windows。

### 平台

支持的 OS：

- `Darwin` -> `darwin`
- `Linux` -> `linux`

支持的 CPU 架构：

- `arm64` / `aarch64` -> `arm64`
- `x86_64` / `amd64` -> `amd64`
- `riscv64` -> `riscv64`

每个工具必须自行确认上游是否提供对应 OS/arch 的 release asset。不能因为 Runtime Baseline 支持某个架构，就默认所有工具都支持该架构。

### 必需命令

`installer.sh` 和所有 `tools/<tool>/install.sh` 可以无额外声明地依赖以下命令：

```text
sh
uname
curl
sed
grep
mktemp
mkdir
mv
rm
rmdir
chmod
tar
```

### 校验命令

工具下载远端二进制时必须做完整性校验。Runtime Baseline v1 要求至少存在一个 SHA-256 校验命令：

```text
shasum
sha256sum
```

macOS 通常提供 `shasum -a 256`；Linux 通常提供 `sha256sum`。工具脚本必须同时兼容这两种命令。

### 依赖规则

- 工具脚本不得隐式依赖 `bash`、`zsh`、`jq`、`python`、`node`、`perl`、`ruby`、`git`、`gh`、`brew`、`npm`、`pip`、`uv`、`pnpm`、`systemctl` 或 `launchctl`。
- 如果某个工具确实需要 Runtime Baseline 之外的命令，必须在该工具目录的文档中声明，并在脚本开头显式检查。
- 统一入口 `tools/installer.sh` 只能检查 Runtime Baseline；工具特有依赖由工具自己的 `install.sh` 检查。
- 缺少必需命令、平台不支持、架构不支持或校验失败时，脚本必须非零退出，不允许静默跳过。

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
- 只使用 Runtime Baseline，或显式声明并检查工具特有依赖

## 当前工具

- `lark-cli`：从 `larksuite/cli` GitHub release 下载最新官方二进制，不使用 npm，不安装官方 skills。支持 `darwin-{amd64,arm64}`、`linux-{amd64,arm64,riscv64}`。
