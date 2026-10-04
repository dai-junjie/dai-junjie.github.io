# Junjie's Blog

Hugo 0.163.3 + [PaperMod](https://github.com/adityatelange/hugo-PaperMod)，发布到 GitHub Pages。

## 本地启动

安装 [Hugo 0.163.3](https://github.com/gohugoio/hugo/releases/tag/v0.163.3)，保证 `hugo` 在 PATH 中。首次克隆时拉取主题：

```bash
git submodule update --init --recursive
./bin/serve
```

访问 <http://localhost:1313/>，按 `Ctrl+C` 停止。修改 Markdown 会自动刷新。换端口可用 `./bin/serve --port 1314`。

## 写文章与插图

```bash
./bin/new "文章标题"
```

文章仍位于 `_posts/`，文件名保持原样；Hugo 将这个目录挂载为文章内容。开头的 `url` 固定文章地址；修改标题或移动文件时保留它，以免旧链接和评论映射变化。

图片仍放在 `assets/images/`，Hugo 将它挂载到网站的同名路径。Markdown 继续使用：

```markdown
![描述](/assets/images/图片.png)
```

带空格的文件名在链接中使用 `%20`。相对的 `assets/images/...` 图片路径也能正常显示，原有 VS Code 和 Obsidian 图片配置无需调整。普通 Markdown、HTML、表格和脚注可以继续使用；Mermaid 仍使用 `mermaid` 代码块。支持 `$...$` 和 `$$...$$` 数学公式，可在文章 front matter 中设置 `math: false` 关闭。

## 构建和发布

```bash
hugo --gc --minify
```

产物位于 `public/`。GitHub Actions 在 `main` 分支推送后构建并发布，自动拉取固定版本的主题。暂时关闭 RSS 订阅，不生成 `/index.xml` 或 `/feed.xml`。

站点设置在 `hugo.yaml`。Giscus 保留原仓库和 `pathname` 映射；目前 `params.giscus.repoId`、`categoryId` 尚为空。填写从 <https://giscus.app/zh-CN> 生成的 ID 并确保仓库安装 Giscus 后，文章才会加载评论组件。

原 Jekyll 内容已迁移；迁移前的配置和文章可以从 Git 历史恢复。调研和迁移验收记录见 [docs/lilian-weng-blog-migration.md](docs/lilian-weng-blog-migration.md)。
