# Tools

按系统维护基础工具和用户目录工具。系统包交给各系统自己的包管理器，直接下载
二进制的工具也放在对应系统目录内，避免一个共享安装器同时处理多个系统的
差异。

工具安装不会随 `chezmoi apply` 或 `chezmoi update` 自动执行。需要在仓库根目录
手动运行：

```bash
sh tools/main.sh
```

`main.sh` 检测当前系统并调用对应脚本。它不会随 `chezmoi apply` 或
`chezmoi update` 自动运行，也不会隐式安装其他系统的工具集。

## 安装层次

每个系统目录都有自己的 `install.sh`。入口脚本直接通过系统包管理器安装基础工具，
再 source 根目录的 `tools/functions.sh` 和本系统需要的
`tools/{system}/get-binaries/*.sh`，最后显式调用对应的 `install_*` 函数。

每个 `tools/{system}/get-binaries/{tool}.sh` 只提供一个安装函数，不在文件加载时
执行安装。
`tools/functions.sh` 只保留通用 helper，例如下载校验、临时目录清理、架构归一化和
用户级 bin 目录准备；它不负责判断当前系统，也不决定安装哪些工具。

三个系统都安装：

- `aliyun-cli`
- `fnm`
- `infisical`
- `lark-cli`
- `pnpm`，并继续安装 `wrangler`
- `uv`，并继续安装 `tccli`

Ubuntu 还通过系统内的工具函数安装 `helm`、`kubectl` 和 Mike Farah 版本的 `yq`。
这些用户级安装函数保留版本检测、下载校验和可执行文件校验逻辑，默认安装到用户
目录，不调用 `sudo`。

## 系统工具集

- macOS 使用 Homebrew 安装 `fd`、`ffmpeg`、`gh`、`helm`、`htop`、`jq`、
  `kubectl`、`pandoc`、`ripgrep`、`vim` 和 `yq`。
- Arch Linux 使用 `sudo pacman -Syu --needed` 安装 `curl`、`fd`、`docker`、
  `docker-buildx`、`docker-compose`、`ffmpeg`、`github-cli`、`go-yq`、`helm`、
  `htop`、`jq`、`kubectl`、`pandoc-cli`、`ripgrep`、`unzip` 和 `vim`。
- Ubuntu 使用 `sudo apt-get` 安装 `curl`、`fd-find`、`ffmpeg`、`gh`、`htop`、
  `jq`、`pandoc`、`ripgrep`、`unzip` 和 `vim`，并在 `~/.local/bin/fd` 创建
  指向 `fdfind` 的链接。Docker Engine、Buildx 和 Compose plugin 从 Docker
  官方 apt 仓库安装；脚本会先移除 Docker 官方文档列出的冲突包。

Ubuntu 安装按三个阶段执行：`prepare.sh` 配置 apt 前置依赖和 Docker 仓库；
`install.sh` 是主入口，安装系统包及 Ubuntu-local 用户级工具；`post-install.sh`
在 Docker 安装完成后配置服务和普通用户权限。Arch 不需要 prepare 阶段，因为当前
系统包都来自机器已有的 pacman 仓库；它只把 Docker 的普通用户权限和 systemd 服务
配置拆到 `post-install.sh`。macOS 目前没有仓库准备、权限调整或服务启用步骤，
所以保持单阶段 `install.sh`。各脚本文件头记录了调用顺序和关键依赖。

macOS 脚本本身不调用 `sudo`。Arch 和 Ubuntu 的系统包安装会请求管理员权限，
随后执行的用户级工具安装阶段不需要管理员权限。

## Docker post-install

Arch 和 Ubuntu 脚本会启动并启用 `docker.service`、`containerd.service`，然后
把执行安装脚本的普通用户加入 `docker` 组。组成员关系需要退出并重新登录后
才会生效；脚本不会自动运行 `newgrp docker`。

`docker` 组可以通过 Docker daemon 获得 root 级权限。这里配置的是 Docker
官方 post-install 文档中的免 `sudo` 模式，不是权限隔离更强的 rootless mode。
