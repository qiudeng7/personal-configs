# Tools

一套同步常用工具的脚本，只依赖少量 runtime baseline

每个工具对应的脚本:
1. 只负责安装可用命令，二进制文件直接下载到 `~/.local/bin` 下，如果是包管理器安装的，就直接全局或用户级安装。
2. 只考虑 macOS 和 Linux，不考虑 Windows；
3. 只依赖 `sh`、`uname`、`curl`、`sed`、`grep`、`mktemp`、`mkdir`、`mv`、`rm`、`rmdir`、`chmod`、`tar`、`unzip`
4. 可复用函数放在 `./functions.sh`
5. 在chezmoi apply时被 `./main.sh` 直接调用
