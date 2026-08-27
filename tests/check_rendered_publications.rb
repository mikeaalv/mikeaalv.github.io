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

# Return the element starting at start_marker through its balanced closing
# </div>, so checks don't leak into unrelated page markup (footer, comments).
def extract_block(html, start_marker)
  start = html.index(start_marker)
  return "" unless start
  depth = 0
  i = start
  while (close_i = html.index("</div>", i))
    open_i = html.index(/<div\b/, i)
    if open_i && open_i < close_i
      depth += 1
      i = open_i + 4
    else
      depth -= 1
      i = close_i + 6
      return html[start...i] if depth.zero?
    end
  end
  html[start..]
end

unless File.file?(PAGE)
  abort "#{PAGE} not found - run `bundle exec jekyll build` first"
end

html = File.read(PAGE, encoding: "UTF-8")
publist = YAML.safe_load(File.read(DATA, encoding: "UTF-8"), aliases: true) || []

entry_count = html.scan(/<div class="pub-entry"[^>]*>/).size
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

pub_block = extract_block(html, '<div class="publist">')
error "publist block missing from page" if pub_block.empty?
error 'page emits empty href="" links' if pub_block.include?('href=""')
error "kramdown escaped closing tags (raw HTML block lost markdown=\"0\"?)" if html.include?("&lt;/div&gt;")

# Ascending numbering: the newest entry (top of the page) is 1., the
# oldest is N. scan preserves document order, so this checks order too.
nums = html.scan(%r{<span class="pub-num">(\d+)\.</span>}).flatten.map(&:to_i)
if nums != (1..publist.size).to_a
  error "pub-num spans are not 1..#{publist.size} in page order (found: #{nums.first(3).join(',')}...)"
end

# Every entry carries an id="pub-N" anchor matching its visible number;
# _pages/research.md deep-links citations as /Publications/#pub-N.
anchor_nums = html.scan(/id="pub-(\d+)"/).flatten.map(&:to_i)
if anchor_nums != (1..publist.size).to_a
  error "pub-N anchors are not 1..#{publist.size} in page order (found #{anchor_nums.size})"
end

# Highlight section: every highlight: true entry is featured with its image.
highlights = publist.select { |p| p["highlight"] }
if highlights.any?
  hl_block = extract_block(html, '<div class="pub-highlight">')
  error "pub-highlight block missing from page" if hl_block.empty?
  highlights.each do |publi|
    label = "highlight (#{publi['title'].to_s[0, 40]}...)"
    error "#{label}: title missing from highlight section" unless rendered?(hl_block, publi["title"].to_s)
    if !blank?(publi["image"]) && !hl_block.include?("/images/#{publi['image']}")
      error "#{label}: image #{publi['image']} missing from highlight section"
    end
  end
  error 'highlight section emits empty src=""' if hl_block.include?('src=""')
end

# Titles render uniformly: the bold-when-highlighted styling was removed.
error "publist still bolds titles (<strong> found)" if pub_block.include?("<strong>")

if @errors.empty?
  puts "Publications page OK: #{entry_count} entries rendered"
  exit 0
else
  @errors.each { |e| puts "ERROR  #{e}" }
  exit 1
end
