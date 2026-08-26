#!/usr/bin/env ruby
# Regression test for the compact publication list rendered by
# _pages/publications.md. Run AFTER `bundle exec jekyll build`:
#
#   ruby tests/check_rendered_publications.rb [site_dir]   # default ../_site
#
# Checks that every entry in _data/publist.yml made it into
# _site/Publications/index.html exactly once, that no empty links are
# emitted for missing paper/code URLs, and that kramdown did not mangle
# the raw HTML block (parse_block_html: true escapes same-line closing
# tags unless the block opts out with markdown="0").
#
# Exit status: 0 = all good, 1 = at least one error.

require "yaml"

SITE_DIR = File.expand_path(ARGV[0] || File.join(__dir__, "..", "_site"))
PAGE = File.join(SITE_DIR, "Publications", "index.html")
DATA = File.expand_path(File.join(__dir__, "..", "_data", "publist.yml"))

@errors = []

def error(msg)
  @errors << msg
end

def blank?(value)
  value.nil? || (value.is_a?(String) && value.strip.empty?)
end

# kramdown normalizes bare "&" to "&amp;" even inside raw HTML blocks,
# so accept either the literal text or its entity-escaped form.
def rendered?(html, text)
  html.include?(text) || html.include?(text.gsub("&", "&amp;"))
end

unless File.file?(PAGE)
  abort "#{PAGE} not found - run `bundle exec jekyll build` first"
end

html = File.read(PAGE, encoding: "UTF-8")
publist = YAML.safe_load(File.read(DATA, encoding: "UTF-8"), aliases: true) || []

entry_count = html.scan('<div class="pub-entry">').size
if entry_count != publist.size
  error "expected #{publist.size} pub-entry blocks, found #{entry_count}"
end

publist.each_with_index do |publi, i|
  label = "entry #{i + 1} (#{publi['title'].to_s[0, 40]}...)"
  error "#{label}: title missing from page" unless rendered?(html, publi["title"].to_s)
  link = publi["link"] || {}
  if !blank?(link["url"]) && !rendered?(html, %(href="#{link["url"]}"))
    error "#{label}: paper link #{link["url"]} missing from page"
  end
  code = publi["code"] || {}
  if !blank?(code["url"]) && !rendered?(html, %(href="#{code["url"]}"))
    error "#{label}: code link #{code["url"]} missing from page"
  end
  if !blank?(publi["display2"]) && !rendered?(html, publi["display2"].to_s)
    error "#{label}: display2 news line missing from page"
  end
end

pub_block = html[/<div class="publist">.*<\/div>\s*<\/div>/m].to_s
error 'page emits empty href="" links' if pub_block.include?('href=""')
error "kramdown escaped closing tags (raw HTML block lost markdown=\"0\"?)" if html.include?("&lt;/div&gt;")

if @errors.empty?
  puts "Publications page OK: #{entry_count} entries rendered"
  exit 0
else
  @errors.each { |e| puts "ERROR  #{e}" }
  exit 1
end
