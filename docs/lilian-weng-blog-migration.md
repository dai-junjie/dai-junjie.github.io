# Lil’Log 页面调研与迁移方案

核查日期：2026-10-04。以下调研正文记录迁移前的状态；实际迁移采用目录挂载，保留 `_posts/` 和 `assets/images/` 的本地路径，当前使用方法见 [README](../README.md)。

结论：Lilian Weng 当前博客使用 **Hugo 0.163.3 + PaperMod**；我们的博客使用 **Jekyll 4.4 + Minimal Mistakes**。如果目标是采用她的页面结构和阅读体验，建议迁移到 Hugo + 官方 PaperMod，保留我们的文章、图片、旧 URL 和评论映射。

她公开的仓库是生成后的静态站点，未发现当前 Hugo 配置、主题源码和构建工作流。因此本文给出的是根据可见页面与官方主题能力制定的迁移方案，不是找回的作者原始配置。[作者首页源码](https://github.com/lilianweng/lilianweng.github.io/blob/95ba34c87d54bc406e3ba7de253ee3b9590b2ead/index.html) · [完整发布仓库树](https://api.github.com/repos/lilianweng/lilianweng.github.io/git/trees/95ba34c87d54bc406e3ba7de253ee3b9590b2ead?recursive=1)

## 1. 检查范围与证据边界

从 [sitemap](https://lilianweng.github.io/sitemap.xml) 的 112 条记录出发，去重为 111 个 URL，再沿页面分页链接检查 12 个分页，共 **123 个 HTML 页面，全部 HTTP 200**：52 篇文章、52 个不同标签 URL、12 个分页、7 个入口页。逐页核查 HTML 中的模板结构、样式资源、目录与脚本；浏览器查看首页、归档、标签、FAQ、文章，并实际验证搜索结果、公式渲染、代码复制按钮和桌面/窄屏布局。没有逐篇评审文章的研究内容。

另外检查了 `404.html` 与搜索索引 `index.json`。搜索索引有 53 条记录，包含 52 篇文章及 FAQ。完整页面检查记录见 [lilian-weng-page-audit.json](lilian-weng-page-audit.json)。该记录中的 `mathjax` 表示页面包含 MathJax 脚本，不代表每页都有公式；`comments` 仅记录检测到的常见评论脚本。[搜索索引](https://lilianweng.github.io/index.json)

当前发布仓库核查基准为 `95ba34c87d54bc406e3ba7de253ee3b9590b2ead`，只有 `master` 分支，无 tags。历史提交显示她在 2022-02-25 迁移到 Hugo；另外的 `lilianweng/lil-log` 是已弃用的 Jekyll 源码，不能把其 `_config.yml` 当成今天的配置。[迁移提交](https://github.com/lilianweng/lilianweng.github.io/commit/425aa20dd3092cc33e369d6cf97ea074ca834510) · [旧仓库 README](https://github.com/lilianweng/lil-log/blob/master/README.md) · [分支](https://api.github.com/repos/lilianweng/lilianweng.github.io/branches?per_page=100) · [tags](https://api.github.com/repos/lilianweng/lilianweng.github.io/tags?per_page=100)

## 2. 各种页面怎么组成

| 页面 | 当前实际效果 | 模板/配置对应 | 我们的迁移建议 |
|---|---|---|---|
| [首页](https://lilianweng.github.io/) | 欢迎语、简介、社交图标，下面按日期倒序列文章卡片；每页 10 篇，卡片含摘要、日期、阅读时间、作者 | PaperMod Home Info 模式；`homeInfoParams`、`socialIcons`、`pagination.pagerSize` | 用我们的站名、简介、GitHub、Email、RSS，展示文章摘要 |
| [文章列表](https://lilianweng.github.io/posts/) | 与首页共用文章卡片，但不含欢迎区 | PaperMod section list | 首页作为主要文章入口即可 |
| [文章](https://lilianweng.github.io/posts/2023-06-23-agent/) | 单栏正文，标题和元信息下方是默认折叠目录；正文图片、公式、脚注、代码；底部标签、前后文章及分享 | single 模板；`ShowToc`、`TocOpen`、`ShowReadingTime`、`ShowPostNavLinks`、`ShowCodeCopyButtons` | 保留阅读时间、目录和代码复制；分享延续我们当前关闭的设置 |
| [归档](https://lilianweng.github.io/archives/) | 按年/月分组，显示篇数及文章元信息 | PaperMod `archives` layout | 保持 `/year-archive/` 地址，换为此模板 |
| [搜索](https://lilianweng.github.io/search/) | 浏览器端搜索，结果可直接进入文章 | PaperMod `search` layout，Fuse.js，首页 JSON 输出 | 增加中文站内搜索，验收中文词和英文技术词 |
| [标签总览](https://lilianweng.github.io/tags/) | 标签按钮与文章数量 | taxonomy terms 模板 | 保留标签数据，采用新展示方式 |
| [单个标签](https://lilianweng.github.io/tags/agent/) | 对应文章卡片列表；文章多时分页 | taxonomy term 模板 | 自动生成，不手写标签页 |
| [FAQ](https://lilianweng.github.io/faq/) | 普通内容页，以问答介绍订阅、联系、更新等 | 内容页及自定义正文 HTML | 保留我们的 `/about/` 内容，没有必要复制她的 FAQ |
| [分类](https://lilianweng.github.io/categories/) | 当前仅有标题、没有分类项，且不在主菜单中 | 分类 terms 模板 | 我们已有分类，保留 `/categories/` |
| [404](https://lilianweng.github.io/404.html) | 简单 404 页面，沿用导航和页脚 | 主题 404 模板 | 使用主题自带页面 |

上述主题能力及配置名称依据 [PaperMod Features](https://github.com/adityatelange/hugo-PaperMod/wiki/Features) 和 [Variables](https://github.com/adityatelange/hugo-PaperMod/wiki/Variables)；作者的实际效果依据表内页面和发布 HTML。可观察效果能对应到主题选项，但不能证明作者配置文件中的键和值完全相同。

## 3. 她的视觉效果主要来自哪里

整体是 PaperMod 的典型排版：系统字体、单栏、留白、浅灰列表背景、白色圆角卡片、黑灰文字、顶部文字导航和深浅色切换。她没有使用我们的作者侧栏，也没有右侧悬浮目录；文章目录位于正文之前，浏览器检查其定位为 `static`。[文章页](https://lilianweng.github.io/posts/2023-06-23-agent/)

| 项目 | 作者发布 CSS 的值 |
|---|---|
| 正文宽度变量 | `--main-width: 720px`，主容器另外包含左右 padding |
| 导航宽度变量 | `--nav-width: 1024px` |
| 常规间距 | `--gap: 24px` |
| 窄屏间距 | 768px 及以下变为 14px |
| 卡片圆角 | 8px |
| 文章标题 | 36px |
| 列表摘要 | 14px，视觉上截取两行 |

来源：[作者发布的 CSS](https://github.com/lilianweng/lilianweng.github.io/blob/95ba34c87d54bc406e3ba7de253ee3b9590b2ead/assets/css/stylesheet.min.8e2f522e170c601ef0b359b6e27078d17e3020e1f4d928afdff4dae588c1e9e4.css)。正文宽度、导航宽度、圆角和间距也与 [官方主题变量](https://github.com/adityatelange/hugo-PaperMod/blob/d3768854d00ad003b0a8dbdba254ce9224377a01/assets/css/core/theme-vars.css) 对应。

需要单独处理的可见差异：

- **公式**：作者全站加载 MathJax 3，支持 `$...$`、`\(...\)`、`$$...$$`、`\[...\]`。这需要数学渲染集成；仅配置主题不够。浏览器在 Agent 文章中实际检测到 16 个渲染后的 `mjx-container`。[发布 HTML](https://github.com/lilianweng/lilianweng.github.io/blob/95ba34c87d54bc406e3ba7de253ee3b9590b2ead/posts/2023-06-23-agent/index.html) · [Hugo 数学公式指南](https://gohugo.io/content-management/mathematics/)
- **元信息**：作者显示 `Date: ... | Estimated Reading Time: ... | Author: ...`；当前官方主题使用中点分隔。如需相同措辞，需要覆盖 `post_meta`，建议我们先使用官方主题的中文表达。[官方模板](https://github.com/adityatelange/hugo-PaperMod/blob/d3768854d00ad003b0a8dbdba254ce9224377a01/layouts/_partials/post_meta.html)
- **标题、代码折行**：作者标题 36px，当前官方主题为 40px；作者代码存在折行规则。可以用少量 CSS 覆盖，待实际预览后决定。[官方文章样式](https://github.com/adityatelange/hugo-PaperMod/blob/d3768854d00ad003b0a8dbdba254ce9224377a01/assets/css/common/post-single.css)
- **主题版本差异**：作者输出使用旧版 `body.dark` 结构；当前官方主题采用 `data-theme` 等新结构。无法从发布文件确定她固定的主题 commit，因此最新主题只能保证同类风格，不能保证像素级一致。

当前页面没有检测到 Giscus、Disqus 或 Utterances 评论组件。她加载了 Google Analytics；我们无需复制她的统计 ID、图标、文章或插图。官方 PaperMod 是 MIT，使用主题时保留许可证；作者发布仓库未发现通用内容许可证。[主题 LICENSE](https://github.com/adityatelange/hugo-PaperMod/blob/d3768854d00ad003b0a8dbdba254ce9224377a01/LICENSE) · [作者仓库](https://github.com/lilianweng/lilianweng.github.io)

## 4. 我们现有博客的迁移量

以下均为本次本地检查结果：

- [Gemfile](https://github.com/dai-junjie/dai-junjie.github.io/blob/2321cd9e71982a615c620a7d03840eef4923940e/Gemfile)、[_config.yml](https://github.com/dai-junjie/dai-junjie.github.io/blob/2321cd9e71982a615c620a7d03840eef4923940e/_config.yml)：Jekyll `~> 4.4`、`minimal-mistakes-jekyll`、9 篇文章，4 张本地图片，4 个页面入口。
- [_data/navigation.yml](https://github.com/dai-junjie/dai-junjie.github.io/blob/2321cd9e71982a615c620a7d03840eef4923940e/_data/navigation.yml)：首页、分类、标签、归档、关于。
- [_includes/head/custom.html](https://github.com/dai-junjie/dai-junjie.github.io/blob/2321cd9e71982a615c620a7d03840eef4923940e/_includes/head/custom.html)：Mermaid 11 渲染集成，迁移必须接回。
- [_plugins/image_path.rb](https://github.com/dai-junjie/dai-junjie.github.io/blob/2321cd9e71982a615c620a7d03840eef4923940e/_plugins/image_path.rb)：把 `assets/images/...` 图片地址补成 `/assets/images/...`。Hugo 不执行 Ruby 插件，迁移时规范正文路径并保留静态目录结构。
- [_pages/year-archive.md](https://github.com/dai-junjie/dai-junjie.github.io/blob/2321cd9e71982a615c620a7d03840eef4923940e/_pages/year-archive.md)：使用 Liquid 循环，不能直接复制给 Hugo；用 archives 模板替代。9 篇文章未发现正文 Liquid 模板依赖。
- [_config.yml](https://github.com/dai-junjie/dai-junjie.github.io/blob/2321cd9e71982a615c620a7d03840eef4923940e/_config.yml)：Giscus 使用 `pathname`，`repo_id`、`category_id` 当前为空。此处只证明本地配置未完整填写，未重新核查 GitHub App 安装状态。
- [.github/workflows/pages.yml](../.github/workflows/pages.yml)：目前用 Ruby 构建 `_site`，再上传 Pages artifact。迁移时保留 Pages 部署步骤，替换构建工具和产物路径即可。

已经运行 `bundle check` 和 `bundle exec jekyll build --destination /tmp/junjie-blog-migration-baseline`，构建通过；存在 Sass 弃用提示，不影响这次构建。此基线包含全部 9 篇文章。当前 shell 未找到 Hugo，因此下方 Hugo 配置是待验证草案，不是已完成迁移。

### URL 必须保留

我们的 `permalink: /:title/` 实际主要依据文章文件名生成路径，而不是文章显示标题。迁移时建议给每篇文章明确填写 Hugo `url`，直接复用本次构建产物的 canonical 路径；不依赖 Hugo 自动从中文标题推导 slug。[Hugo URL 文档](https://gohugo.io/content-management/urls/)

| 原文章文件名（省略日期） | 要保留的路径 |
|---|---|
| `agent-quality-issue.md` | `/agent-quality-issue/` |
| `first-demo.md` | `/first-demo/` |
| `loop-engineering.md` | `/loop-engineering/` |
| `markdown-cheatsheet.md` | `/markdown-cheatsheet/` |
| `drivergenerationbenchmark.md` | `/drivergenerationbenchmark/` |
| `关于驱动生成这次科研课题的总结.md` | `/关于驱动生成这次科研课题的总结/` |
| `逻辑模组-迷茫的底层真相.md` | `/逻辑模组-迷茫的底层真相/` |
| `不要向-Agent-许愿：科研中使用-AI-的真正难点是明确自己的意图.md` | `/不要向-Agent-许愿-科研中使用-AI-的真正难点是明确自己的意图/` |
| `如何看待AI工具.md` | `/如何看待AI工具/` |

注意中文文件名中的全角冒号在当前 URL 中已经变成连字符。另一个例子是最后一篇显示标题为“如何把思考和Agent工具结合”，URL 却是 `/如何看待AI工具/`。固定 URL 可同时保留外链和 Giscus pathname 映射。原页面也保留 `/about/`、`/categories/`、`/tags/`、`/year-archive/`。

### 文件怎么对应

| 当前文件/目录 | Hugo 中的对应 |
|---|---|
| `_config.yml` | `hugo.yaml`，重新映射设置，不直接改名 |
| `_posts/*.md` | `content/posts/*.md`，保留正文、日期、tags、categories，补 `url` |
| `_pages/about.md` | `content/about.md`，补 `url: /about/` |
| `_pages/year-archive.md` | `content/archives.md`，`layout: archives`、`url: /year-archive/` |
| 分类/标签页面 | Hugo taxonomy 自动生成；我们保留两个 taxonomy |
| `assets/images/*` | `static/assets/images/*`，访问路径继续为 `/assets/images/*` |
| `_includes/head/custom.html` | 通过主题扩展 partial 或 Mermaid render hook 接入 |
| `_plugins/image_path.rb` | 转换时修正图片链接，不移植运行时插件 |
| Giscus 主题集成 | 自建 comments partial，保留 repo、category 和 pathname 规则 |
| `bin/new` | 写到 `content/posts/`，日期转 ISO 8601，生成明确 URL |
| `bin/serve` | 保持入口名，内部改为 `hugo server` |
| `_site` | `public`，由 Actions 上传 |

现有 Markdown 语法手册含 HTML、脚注、表格和 Mermaid，适合用作迁移验收样本。分类/标签中的空 YAML 值应转为空列表或省略。不能机械照抄 Jekyll 的 `layout: single`、`toc_sticky`、`author_profile` 等主题字段。`markdown-cheatsheet` 文件名日期为 7 月 2 日，但 front matter 日期为 7 月 1 日，迁移应保留正文元数据日期。

## 5. 推荐配置草案

下方是给我们博客的配置，不是作者配置。主题采用官方仓库，固定到经过核查的 commit `d3768854d00ad003b0a8dbdba254ce9224377a01`；本地与 CI 固定同一个 Hugo 版本。该主题声明最低 Hugo 0.146.0，作者当前生成器为 0.163.3，可用 0.163.3 作为首轮验证版本。[theme.toml](https://github.com/adityatelange/hugo-PaperMod/blob/d3768854d00ad003b0a8dbdba254ce9224377a01/theme.toml)

```yaml
baseURL: https://dai-junjie.github.io/
title: "Junjie's Blog"
theme: PaperMod
defaultContentLanguage: zh
locale: zh-CN
hasCJKLanguage: true

pagination:
  pagerSize: 10

taxonomies:
  category: categories
  tag: tags

outputs:
  home: [HTML, RSS, JSON]

params:
  env: production
  author: daijunjie
  description: 技术笔记与思考
  defaultTheme: auto
  disableThemeToggle: false
  mainSections: [posts]
  ShowReadingTime: true
  ShowToc: true
  TocOpen: false
  ShowPostNavLinks: true
  ShowCodeCopyButtons: true
  ShowBreadCrumbs: false
  ShowShareButtons: false
  DateFormat: "2006-01-02"
  homeInfoParams:
    Title: "Junjie's Blog"
    Content: "系统 · 工程 · 研究。记录技术笔记与思考。"
  socialIcons:
    - name: github
      url: https://github.com/dai-junjie
    - name: email
      url: mailto:junjiedai@zju.edu.cn
    - name: rss
      url: /index.xml

menu:
  main:
    - {name: 首页, url: /, weight: 10}
    - {name: 分类, url: /categories/, weight: 20}
    - {name: 标签, url: /tags/, weight: 30}
    - {name: 归档, url: /year-archive/, weight: 40}
    - {name: 搜索, url: /search/, weight: 50}
    - {name: 关于, url: /about/, weight: 60}

markup:
  goldmark:
    renderer:
      unsafe: true
```

`hasCJKLanguage` 用于中文阅读时间、字数和摘要；`unsafe` 用于保留我们现有的正文 HTML。数学公式如需启用，另加 Goldmark passthrough 及 MathJax partial；`params.math` 自身不会自动加载 MathJax。Mermaid 同样需要独立集成。[Hugo CJK 配置](https://gohugo.io/configuration/all/#hascjklanguage) · [数学集成](https://gohugo.io/content-management/mathematics/)

归档和搜索各需要一个内容文件；普通 About 页面可关闭目录及无关文章元信息。当前官方主题使用 `layouts/_partials/`；部分 wiki 示例仍写 `layouts/partials/`，实现时以固定主题源码中的实际引用为准。

```yaml
# content/archives.md 的 front matter
---
title: 归档
layout: archives
url: /year-archive/
ShowToc: false
---
```

```yaml
# content/search.md 的 front matter
---
title: 搜索
layout: search
url: /search/
ShowToc: false
---
```

RSS 新地址是 `/index.xml`；旧站构建有 `/feed.xml`，迁移时保留 `/feed.xml` 的 XML 输出兼容地址。仅用 HTML aliases 跳转不适合替代 feed。分类/标签当前使用页面内锚点，换成独立 taxonomy 页后要评估已分享的 `/tags/#...`、`/categories/#...` 是否需要兼容锚点。文章内部标题锚点也要检查，因 Kramdown 与 Goldmark 的生成规则可能不同。

## 6. 执行顺序与验收标准

1. **先在独立迁移分支准备 Hugo 源码与官方主题**，固定版本并建立本地预览。验收：首页欢迎区、卡片、导航、目录位置与目标风格一致。
2. **转换 9 篇文章、About、归档及全部图片**，直接保留上表 URL。验收：文章数、标题、日期、tags、categories 与基线一致；9 个旧 URL 均能打开对应文章，图片可访问。
3. **接回 Mermaid、搜索、公式和 Giscus**。验收：语法手册中的两种 Mermaid 与 Demo 流程图正常；中文/英文查询均有预期结果；公式无丢失反斜杠；评论脚本使用原 pathname 和完整配置。Giscus 外部配置若尚未完成，单独记录实际阻塞，不把页面构建成功算作评论验证通过。
4. **替换 Pages 构建步骤**：checkout 含主题依赖，安装固定 Hugo，`hugo --gc --minify`，上传 `public`，沿用当前 configure/upload/deploy 流程。验收：本地 production 构建通过、链接检查通过、GitHub Actions 实际通过。[Hugo Pages 文档](https://gohugo.io/hosting-and-deployment/hosting-on-github/)
5. **检查正式站**：首页、归档、标签、分类、搜索、About、旧文章链接、图片、RSS、评论及深浅色；验证桌面和窄屏。需要回滚时恢复原构建配置并重新部署原源码版本。

本次交付仅新增调研文档和页面检查记录，现有主题、文章及部署配置未修改；没有安装 Hugo、提交或发布迁移。

## 7. 实施与验收记录（2026-10-04）

上面的第 6 节末句记录的是调研阶段交付；用户随后授权开始迁移，现已完成本地实现。实际使用 Hugo 的目录挂载，保留 `_posts/`、`assets/images/`、原文件名，以及 VS Code/Obsidian 配置。所有文章正文未改，仅规范 front matter 并固定旧 URL。

- Hugo 0.163.3 已安装；官方 PaperMod 固定为上文 commit，原 Jekyll 配置和模板已由新配置替代。
- 9 篇正文的迁移前后 SHA-256 完全相同；标题、日期、标签、分类与旧 URL 均一致。4 张原图及发布后的图片内容 SHA-256 相同。
- `/index.xml` 与旧 `/feed.xml` 均包含 9 篇文章；搜索索引包含 9 篇文章和 About，Fuse 实测“控制论”、`driver`、`loop` 均命中预期文章。
- 检查了 48 个生成的 HTML 文件中的 785 个本地链接、文件引用及锚点，没有缺失目标。现有文章标题锚点与旧输出对比，没有发现丢失。
- 3 个 Mermaid 定义在输出 HTML 中保留，脚本按 DOM 中是否存在图块加载，避免主题缓存页脚导致遗漏。临时样例构建验证了相对图片、带空格的图片名、TeX、HTML 和配置完整时的 Giscus pathname 属性。
- `bin/serve`、`bin/new`、YAML 及 CI shell 语法检查通过；新建文章脚本实际测试了其他工作目录、标题引号、空参数及拒绝覆盖已有文件。
- 上游主题使用两个已弃用的 Hugo 语言字段，构建会给出警告；固定版本下构建通过，未修改第三方主题源码。

浏览器安全策略拒绝了读取现有 `http://localhost:1313/` 标签页的动作，理由是 URL 协议被判定为不允许。未绕过策略，所以未完成浏览器中的实际图形、公式和响应式视觉检查。HTTP、生产构建和上述内容检查不受此限制。

Giscus 的 `repoId`、`categoryId` 仍为空，保留为独立配置前提。迁移位于 `codex/hugo-papermod`，没有推送或发布，因此未声称 GitHub Actions 或线上站点已验证。详细内容校验记录见 [hugo-migration-validation.json](hugo-migration-validation.json)，当前启动和写作方式见 [README](../README.md)。
