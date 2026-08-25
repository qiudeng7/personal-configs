# Tools

按系统维护基础工具，并用 common 安装器补充适合用户目录安装的跨系统工具。

工具安装不会随 `chezmoi apply` 或 `chezmoi update` 自动执行。需要在仓库根目录
手动运行：

```bash
sh tools/main.sh
```

`main.sh` 检测当前系统并调用对应脚本。它不会随 `chezmoi apply` 或
`chezmoi update` 自动运行，也不会隐式安装其他系统的工具集。

## 安装层次

每个系统脚本先通过系统包管理器安装基础工具，再按明确给出的顺序调用
`tools/common/main.sh`。common 入口只运行调用方指定的安装器；指定名称没有
对应的 `install.sh` 时会立即报错。

三个系统共同通过 common 安装：

- `aliyun-cli`
- `fnm`
- `infisical`
- `lark-cli`
- `pnpm`，并继续按 `pnpm/list.txt` 安装 `wrangler`
- `uv`，并继续按 `uv/list.txt` 安装 `tccli`

Ubuntu 还通过 common 安装 `helm`、`kubectl` 和 Mike Farah 版本的 `yq`。
common 安装器保留各工具原有的版本检测、下载校验和可执行文件校验逻辑，
默认安装到用户目录，不调用 `sudo`。

## 系统工具集

- macOS 使用 Homebrew 安装 `fd`、`ffmpeg`、`gh`、`helm`、`htop`、`jq`、
  `kubectl`、`pandoc`、`ripgrep`、`vim` 和 `yq`。
- Arch Linux 使用 `sudo pacman -Syu --needed` 安装 `curl`、`fd`、`ffmpeg`、
  `github-cli`、`go-yq`、`helm`、`htop`、`jq`、`kubectl`、`pandoc-cli`、
  `ripgrep`、`unzip` 和 `vim`。
- Ubuntu 使用 `sudo apt-get` 安装 `curl`、`fd-find`、`ffmpeg`、`gh`、`htop`、
  `jq`、`pandoc`、`ripgrep`、`unzip` 和 `vim`，并在 `~/.local/bin/fd` 创建
  指向 `fdfind` 的链接。

macOS 脚本本身不调用 `sudo`。Arch 和 Ubuntu 的系统包安装会请求管理员权限，
随后执行的 common 安装阶段不需要管理员权限。
