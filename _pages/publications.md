---
title: "Yue Wu - Publications"
layout: gridlay
excerpt: "Yue Wu -- Publications."
sitemap: false
permalink: /Publications/
---


# Publications

## Highlight

<div class="pub-highlight" markdown="0">
{%- for publi in site.data.publist %}
{%- if publi.highlight %}
<div class="well">
<pubtit>{{ publi.title }}</pubtit>
{%- if publi.image %}
<p><img src="{{ site.url }}{{ site.baseurl }}/images/{{ publi.image }}" class="img-responsive" width="33%" style="float: left" alt="{{ publi.title }}" /></p>
{%- endif %}
{%- if publi.description %}
<p>{{ publi.description }}</p>
{%- endif %}
<p><em>{{ publi.authors | strip }}</em></p>
<p><strong><a href="{{ publi.link.url }}">{{ publi.link.display | strip }}</a></strong>{% if publi.code.url %} &middot; <a href="{{ publi.code.url }}">{{ publi.code.display | default: "code" }}</a>{% endif %}</p>
{%- if publi.display2 %}
<p class="text-danger"><strong>{{ publi.display2 }}</strong></p>
{%- endif %}
</div>
{%- endif %}
{%- endfor %}
</div>

## Full publication list

See the full list of publications at [Google Scholar](https://scholar.google.com/citations?user=QE1tszYAAAAJ&hl=en)

<div class="publist" markdown="0">
{%- for publi in site.data.publist %}
<div class="pub-entry" id="pub-{{ forloop.index }}">
<span class="pub-num">{{ forloop.index }}.</span>
<div class="pub-title">{{ publi.title }}</div>
<div class="pub-authors"><em>{{ publi.authors | strip }}</em></div>
<div class="pub-meta">{{ publi.link.display | strip }}{% if publi.link.url %} &nbsp;<a href="{{ publi.link.url }}">{{ publi.paper | default: "paper" }}</a>{% endif %}{% if publi.code.url %} &middot; <a href="{{ publi.code.url }}">{{ publi.code.display | default: "code" }}</a>{% endif %}</div>
{%- if publi.display2 %}
<div class="pub-news">{{ publi.display2 }}</div>
{%- endif %}
</div>
{%- endfor %}
</div>


