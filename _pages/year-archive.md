---
title: 归档
permalink: /year-archive/
author_profile: false
---

{% assign postsByYear = site.posts | group_by_exp: "post", "post.date | date: '%Y'" %}
{% for year in postsByYear %}
## {{ year.name }}
{% for post in year.items %}
- [{{ post.title }}]({{ post.url }}) <small>{{ post.date | date: "%Y/%m/%d" }}</small>
{% endfor %}
{% endfor %}
