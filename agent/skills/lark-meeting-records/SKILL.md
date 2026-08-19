---
name: lark-meeting-records
description: Read Feishu/Lark meeting-record links and tokens, including AI meeting summaries, verbatim Docx transcripts, Minutes records, and Note IDs. Use only when the user provides a Feishu/Lark meeting-record URL or token, or explicitly asks to retrieve meeting records from Feishu/Lark. Do not use for generic documents, local Markdown, spreadsheets, app or UI development, or non-Feishu meetings.
---

# 飞书会议记录

使用本机的 `lark-cli` 只读访问会议 AI 整理稿、逐字原文和妙记产物。保持来源边界清楚，不创建或修改文档，不上传媒体，也不调整资源权限。

## 调用约定

每条命令都关闭更新与 skill 同步提示，避免读取任务改变本机配置：

```bash
LARKSUITE_CLI_NO_UPDATE_NOTIFIER=1 LARKSUITE_CLI_NO_SKILLS_NOTIFIER=1 lark-cli ...
```

默认使用 `--as user`。不要先把 `auth status` 当作硬门槛：公开文档在 user token 显示 `needs_refresh` 时仍可能正常读取。先执行实际读取；只有读取返回认证或 scope 错误时才进入授权流程。

## 按输入类型读取

### Docx 或 Wiki 链接

AI 整理稿和逐字原文通常都是 `/docx/` 链接。直接保留完整 URL 交给 CLI：

```bash
LARKSUITE_CLI_NO_UPDATE_NOTIFIER=1 LARKSUITE_CLI_NO_SKILLS_NOTIFIER=1 \
  lark-cli docs +fetch --doc '<docx-or-wiki-url>' \
  --doc-format markdown --detail simple --as user
```

不要用浏览器抓取公开页面，也不要手工猜 token。CLI 的结果包含正文、revision 和身份信息；标题通常位于正文开头，不能假设存在独立的 `title` 字段。

### Minutes 链接或 minute token

从 `/minutes/<token>` 链接取最后一个路径段并去掉 query。先读取结构化 AI 产物及 `note_id`：

```bash
LARKSUITE_CLI_NO_UPDATE_NOTIFIER=1 LARKSUITE_CLI_NO_SKILLS_NOTIFIER=1 \
  lark-cli minutes +detail --minute-tokens '<minute-token>' \
  --summary --todo --chapter --keyword --as user
```

### Note ID

用 Note 详情确定 AI 稿与原文的真实文档 token：

```bash
LARKSUITE_CLI_NO_UPDATE_NOTIFIER=1 LARKSUITE_CLI_NO_SKILLS_NOTIFIER=1 \
  lark-cli note +detail --note-id '<note-id>' --as user
```

- `note_display_type=normal`：读取返回的 `note_doc_token` 和 `verbatim_doc_token`，分别再走 `docs +fetch`。
- `note_display_type=unified`：用下列命令读原始逐字记录：

```bash
LARKSUITE_CLI_NO_UPDATE_NOTIFIER=1 LARKSUITE_CLI_NO_SKILLS_NOTIFIER=1 \
  lark-cli note +transcript --note-id '<note-id>' --as user
```

如果只有 Minutes 且无法取得 Note/Docx 原文，而用户确实需要逐字稿，可使用 `minutes +detail --transcript`。该命令会写文件，必须在新建的临时目录里执行，并将 `--output-dir` 指向临时目录内的相对路径；读完后只删除这个已确认的临时目录。

## AI 稿与原文的处理原则

- 用户同时给出 AI 整理稿和逐字原文时，两份都读取。
- 独立总结、事实核对和引用以逐字原文为准；AI 整理稿用于快速定位议题、行动项和章节。
- 明确标注内容来自“AI 整理稿”还是“逐字原文”，不要把 AI 推断写成参会人原话。
- 默认输出精炼总结和必要的出处说明，不整篇复述逐字稿；用户明确要求时再展开。
- 记录标题、会议时间、输入链接及可验证的关联关系。发现两份内容冲突时，指出差异而不是静默合并。
- 如果返回结果没有 `note_id`、原文 token 或逐字稿入口，明确说明当前拿不到，不尝试枚举或猜测 token。

## 私有记录与授权

私有记录仍先直接读取。仅当实际命令返回 `missing_scope`、token 失效或未登录时：

1. 从 CLI 错误中取最小必需 scope，不额外申请无关业务域。
2. 发起 split-flow：

   ```bash
   lark-cli auth login --scope '<missing-scope>' --no-wait --json
   ```

3. 将返回的 `verification_url` 原样给用户，并用 `lark-cli auth qrcode` 展示二维码。
4. 等用户确认授权完成后，再执行：

   ```bash
   lark-cli auth login --device-code '<device-code>'
   ```

权限拒绝或资源 ACL 不允许访问时，不猜 scope、不自动申请资源权限；说明具体失败点，请用户共享记录或明确授权。任何时候都不要输出 app secret、access token 或其他凭证。
