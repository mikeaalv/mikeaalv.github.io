---
title: "Wu Lab - Research"
layout: textlay
excerpt: "Wu Lab -- Research directions"
sitemap: false
permalink: /Research/
---

# Research directions

<div class="researchlist" markdown="0">
{%- for direction in site.data.research %}
<h2 id="{{ direction.title | slugify }}">{{ direction.title }}</h2>
<p><img src="{{ site.url }}{{ site.baseurl }}/images/researchpic/{{ direction.image }}" class="img-responsive" width="{{ direction.width }}" style="margin: 15px auto" alt="{{ direction.alt }}" /></p>
{{ direction.text | markdownify }}
{%- endfor %}
</div>
