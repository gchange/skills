# GChange Skills

自定义 MCP Skills 集合，用于扩展 Clawdbot 能力。

## 目录结构

```
skills/
├── <skill-name>/
│   ├── SKILL.md          # 技能说明文档（必需）
│   ├── skill.json        # 技能元数据
│   ├── scripts/          # 脚本文件
│   └── references/       # 参考文档
└── ...
```

## 如何创建新 Skill

1. 在根目录创建技能文件夹
2. 添加 `SKILL.md`（技能说明，Clawdbot 会读取）
3. 添加 `skill.json`（元数据）
4. 可选：添加 `scripts/`、`references/` 等

### skill.json 示例

```json
{
  "name": "my-skill",
  "description": "技能简要描述",
  "version": "1.0.0",
  "author": "gchange",
  "homepage": "https://github.com/gchange/skills",
  "metadata": {
    "clawdbot": {
      "emoji": "🔧",
      "requires": {
        "bins": ["some-cli"]
      }
    }
  }
}
```

### SKILL.md 模板

```markdown
---
name: my-skill
description: 技能的详细描述
---

# My Skill

技能使用说明...

## 快速开始

\`\`\`bash
# 示例命令
\`\`\`

## 常用操作

- 操作 1
- 操作 2
```

## 安装 Skill

将技能文件夹复制到 Clawdbot skills 目录：

```bash
cp -r ./my-skill ~/.clawdbot/skills/
# 或
cp -r ./my-skill /root/clawd/skills/
```

## License

MIT
