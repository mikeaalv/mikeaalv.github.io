---
title: "Yue Wu - Publications"
layout: gridlay
excerpt: "Yue Wu -- Publications."
sitemap: false
permalink: /Publications/
---


# Publications

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

<!-- {% assign number_printed = 0 %}
{% for publi in site.data.publist %}

{% assign even_odd = number_printed | modulo: 2 %}

{% if even_odd == 0 %}
<div class="row">
{% endif %}

<div class="col-sm-6 clearfix">
 <div class="well">
  <pubtit>{{ publi.title }}</pubtit>
  <img src="{{ site.url }}{{ site.baseurl }}/images/pubpic/{{ publi.image }}" class="img-responsive" width="33%" style="float: left" />
  <p>{{ publi.description }}</p>
  <p><em>{{ publi.authors }}</em></p>
  <p><strong><a href="{{ publi.link.url }}">{{ publi.link.display }}</a></strong></p>
  <p class="text-danger"><strong> {{ publi.news1 }}</strong></p>
  <p> {{ publi.news2 }}</p>
 </div>
</div>

{% assign number_printed = number_printed | plus: 1 %}

{% if even_odd == 1 %}
</div>
{% endif %}

{% endfor %}

{% assign even_odd = number_printed | modulo: 2 %}
{% if even_odd == 1 %}
</div>
{% endif %}

<p> &nbsp; </p> -->



