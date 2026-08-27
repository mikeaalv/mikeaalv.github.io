---
title: "Wu Lab - Team"
layout: textlay
excerpt: "Wu Lab team members"
sitemap: false
permalink: /Team/
---

# Team

<div class="teamlist" markdown="0">
{%- for member in site.data.team_members %}
<div class="member-entry{% if member.you %} member-you{% endif %}">
{%- if member.you %}
<a href="{{ site.url }}{{ site.baseurl }}/Opportunities/"><img class="member-photo" src="{{ site.url }}{{ site.baseurl }}/images/teampic/{{ member.photo }}" alt="{{ member.name }}" /></a>
{%- else %}
<img class="member-photo" src="{{ site.url }}{{ site.baseurl }}/images/teampic/{{ member.photo }}" alt="{{ member.name }}" />
{%- endif %}
<div class="member-info">
<h3 class="member-name">{% if member.you %}<a href="{{ site.url }}{{ site.baseurl }}/Opportunities/">{{ member.name }}</a>{% else %}{{ member.name }}{% endif %}</h3>
<p class="member-role">{{ member.role }}</p>
{%- if member.links %}
<div class="member-links">
{%- for link in member.links %}
<a href="{{ link.url }}" title="{{ link.name }}" aria-label="{{ member.name }} on {{ link.name }}"><img src="{{ site.url }}{{ site.baseurl }}/images/logopic/{{ link.logo }}" alt="{{ link.name }}" /></a>
{%- endfor %}
</div>
{%- endif %}
<div class="member-bio">{{ member.bio | markdownify }}</div>
</div>
</div>
{%- endfor %}
</div>
