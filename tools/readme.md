# Tools

一套同步常用工具的脚本，只依赖少量 runtime baseline

每个工具对应的脚本:
1. 只考虑 macOS 和 Linux，不考虑 Windows；
2. 只依赖 `sh`、`uname`、`curl`、`sed`、`grep`、`mktemp`、`mkdir`、`mv`、`rm`、`rmdir`、`chmod`、`tar`、`unzip`
3. 只负责获取最新版的二进制文件并放到 `~/.local/bin` 下
4. 可复用函数放在 `./functions.sh`
5. 在chezmoi apply时被 `./main.sh` 直接调用
