"""提交规模业务规则。"""

from pathlib import Path
import sys
from typing import List, Tuple


HOOKS_DIR = Path(__file__).resolve().parent.parent
if str(HOOKS_DIR) not in sys.path:
    sys.path.insert(0, str(HOOKS_DIR))

from functions import staged_change_line_count, staged_file_line_count, staged_paths


MAX_CHANGED_FILE_LINES = 500
MAX_COMMIT_CHANGED_LINES = 3000


def oversized_staged_files(paths: List[str]) -> List[Tuple[str, int]]:
    """返回暂存区版本超过单文件长度限制的文件。"""
    violations = []
    for path in paths:
        line_count = staged_file_line_count(path)
        if line_count > MAX_CHANGED_FILE_LINES:
            violations.append((path, line_count))
    return violations


def main(args: List[str]) -> int:
    if args:
        print("用法：commit_size_limitation/main.py", file=sys.stderr)
        return 2

    paths = staged_paths()
    oversized_files = oversized_staged_files(paths)
    if oversized_files:
        print(f"检测到超过 {MAX_CHANGED_FILE_LINES} 行的暂存文件：", file=sys.stderr)
        for path, line_count in oversized_files:
            print(f"  {path} ({line_count} 行)", file=sys.stderr)
        print("\n请拆分文件、减少单文件职责，或在确有必要时使用 git commit --no-verify。", file=sys.stderr)
        return 1

    change_line_count = staged_change_line_count()
    if change_line_count > MAX_COMMIT_CHANGED_LINES:
        print(
            f"本次提交变更过大：新增+删除共 {change_line_count} 行，"
            f"限制为 {MAX_COMMIT_CHANGED_LINES} 行。",
            file=sys.stderr,
        )
        print("\n请拆成更小的提交，或在确有必要时使用 git commit --no-verify。", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
