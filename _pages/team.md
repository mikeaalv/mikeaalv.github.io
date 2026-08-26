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
<div class="member-entry">
<img class="member-photo" src="{{ site.url }}{{ site.baseurl }}/images/teampic/{{ member.photo }}" alt="{{ member.name }}" />
<div class="member-info">
<h3 class="member-name">{{ member.name }}</h3>
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
<div class="member-entry member-you">
<a href="{{ site.url }}{{ site.baseurl }}/Opportunities/"><img class="member-photo" src="{{ site.url }}{{ site.baseurl }}/images/teampic/you.svg" alt="You?" /></a>
<div class="member-info">
<h3 class="member-name"><a href="{{ site.url }}{{ site.baseurl }}/Opportunities/">You?</a></h3>
<p class="member-role">Future lab member</p>
<div class="member-bio"><p>We welcome trainees from nutrition and physiology as well as the quantitative sciences. See the <a href="{{ site.url }}{{ site.baseurl }}/Opportunities/">opportunities to join the lab</a>.</p></div>
</div>
</div>
</div>
