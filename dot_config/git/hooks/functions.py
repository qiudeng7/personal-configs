"""暂存区读取辅助函数。"""

import subprocess
import sys
from typing import List


def run_git(args: List[str]) -> bytes:
    """执行 Git 命令并返回 stdout bytes。"""
    result = subprocess.run(
        ["git", *args],
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if result.returncode != 0:
        error = result.stderr.decode("utf-8", errors="replace").strip()
        print(error or f"Git 命令执行失败：git {' '.join(args)}", file=sys.stderr)
        raise SystemExit(result.returncode)

    return result.stdout


def staged_paths() -> List[str]:
    """返回本次提交新增、复制、修改、重命名或变更类型的路径。"""
    output = run_git(
        [
            "diff",
            "--cached",
            "--name-only",
            "--diff-filter=ACMRT",
            "-z",
        ]
    )
    return [
        path.decode("utf-8", errors="surrogateescape")
        for path in output.split(b"\0")
        if path
    ]


def staged_file_line_count(path: str) -> int:
    """返回暂存区中文件内容的行数；二进制内容按字节换行粗略统计。"""
    content = run_git(["show", f":{path}"])
    if not content:
        return 0

    line_count = content.count(b"\n")
    if not content.endswith(b"\n"):
        line_count += 1
    return line_count


def staged_change_line_count() -> int:
    """返回本次提交的新增行与删除行总数；二进制文件不计入。"""
    output = run_git(["diff", "--cached", "--numstat", "--diff-filter=ACMRT", "-z"])
    if not output:
        return 0

    fields = [field for field in output.split(b"\0") if field]
    total = 0
    for field in fields:
        columns = field.split(b"\t")
        if len(columns) < 3 or columns[0] == b"-" or columns[1] == b"-":
            continue
        total += int(columns[0]) + int(columns[1])
    return total
