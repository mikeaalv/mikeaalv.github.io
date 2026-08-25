#!/usr/bin/env ruby
# Validate the YAML content files in _data/.
#
# A syntax error in ANY _data/*.yml file breaks the whole Jekyll/GitHub Pages
# build, so every file is parse-checked. The two files actually rendered by
# templates (publist.yml, news.yml) are additionally checked against the
# fields _pages/publications.md and _includes/news.html expect.
#
# Usage:
#   ruby tests/validate_data.rb [data_dir]   # data_dir defaults to ../_data
#
# Exit status: 0 = all good (warnings allowed), 1 = at least one error.
#
# Ruby stdlib only; works on the macOS system Ruby (2.6) and CI Ruby (3.3).

require "yaml"
require "uri"
require "date"

DATA_DIR = File.expand_path(ARGV[0] || File.join(__dir__, "..", "_data"))

PUBLIST_ALLOWED_KEYS = %w[
  title image description authors link highlight display2 paper code news1 news2
].freeze
NEWS_ALLOWED_KEYS = %w[date headline].freeze

@errors = []
@warnings = []

def error(file, msg)
  @errors << "#{file}: #{msg}"
end

def warning(file, msg)
  @warnings << "#{file}: #{msg}"
end

def blank?(value)
  value.nil? || (value.is_a?(String) && value.strip.empty?)
end

def valid_http_url?(value)
  uri = URI.parse(value)
  (uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)) && !uri.host.to_s.empty?
rescue URI::InvalidURIError
  false
end

# Mirror Jekyll's safe YAML loading (dates allowed, no arbitrary objects).
def load_yaml(text, filename)
  YAML.safe_load(text, permitted_classes: [Date, Time], aliases: true, filename: filename)
rescue ArgumentError
  # Older Psych (< 3.1) uses positional arguments.
  YAML.safe_load(text, [Date, Time], [], true, filename)
end

# entry label like: entry 3 ("Modifiable Factors Affecting the...")
def entry_label(index, entry)
  title = entry.is_a?(Hash) ? entry["title"].to_s.strip : ""
  short = title.length > 45 ? "#{title[0, 45]}..." : title
  short.empty? ? "entry #{index + 1}" : "entry #{index + 1} (\"#{short}\")"
end

def check_publist(file, entries)
  seen_titles = {}
  entries.each_with_index do |entry, i|
    label = entry_label(i, entry)
    unless entry.is_a?(Hash)
      error(file, "#{label}: expected a mapping with title/authors/link fields, got #{entry.class}")
      next
    end

    %w[title authors paper].each do |key|
      error(file, "#{label}: required field `#{key}` is missing or empty") if blank?(entry[key])
    end

    link = entry["link"]
    if !link.is_a?(Hash)
      error(file, "#{label}: `link` must be a mapping with `url` and `display`")
    else
      if blank?(link["url"])
        error(file, "#{label}: `link.url` is missing or empty (the paper link would be dead)")
      elsif !valid_http_url?(link["url"])
        error(file, "#{label}: `link.url` is not a valid http(s) URL: #{link['url'].inspect}")
      end
      error(file, "#{label}: `link.display` is missing or empty") if blank?(link["display"])
    end

    if entry.key?("highlight") && ![true, false].include?(entry["highlight"])
      error(file, "#{label}: `highlight` must be an unquoted true or false " \
                  "(got #{entry['highlight'].inspect}; note Liquid treats the string \"false\" as true)")
    end

    code = entry["code"]
    if !code.nil?
      if !code.is_a?(Hash)
        error(file, "#{label}: `code` must be a mapping with `url` and `display`")
      else
        url_blank = blank?(code["url"])
        display_blank = blank?(code["display"])
        if url_blank != display_blank
          error(file, "#{label}: `code.url` and `code.display` must be filled together " \
                      "(one is empty, which renders an invisible or dead code link)")
        elsif !url_blank && !valid_http_url?(code["url"])
          error(file, "#{label}: `code.url` is not a valid http(s) URL: #{code['url'].inspect}")
        end
      end
    end

    unless blank?(entry["title"])
      key = entry["title"].strip.downcase.gsub(/\s+/, " ")
      if seen_titles.key?(key)
        error(file, "#{label}: duplicate of entry #{seen_titles[key] + 1} (same title)")
      else
        seen_titles[key] = i
      end
    end

    (entry.keys - PUBLIST_ALLOWED_KEYS).each do |key|
      warning(file, "#{label}: unknown field `#{key}` (typo?) — templates will silently ignore it")
    end
  end
end

def check_news(file, entries)
  entries.each_with_index do |entry, i|
    label = "entry #{i + 1}"
    unless entry.is_a?(Hash)
      error(file, "#{label}: expected a mapping with `date` and `headline`, got #{entry.class}")
      next
    end
    error(file, "#{label}: required field `date` is missing or empty") if blank?(entry["date"])
    error(file, "#{label}: required field `headline` is missing or empty") if blank?(entry["headline"])
    (entry.keys - NEWS_ALLOWED_KEYS).each do |key|
      warning(file, "#{label}: unknown field `#{key}` (typo?) — templates will silently ignore it")
    end
  end
end

unless File.directory?(DATA_DIR)
  warn "ERROR: data directory not found: #{DATA_DIR}"
  exit 1
end

files = Dir[File.join(DATA_DIR, "*.{yml,yaml}")].sort
if files.empty?
  warn "ERROR: no YAML files found in #{DATA_DIR}"
  exit 1
end

puts "Validating #{files.length} data files in #{DATA_DIR}"

files.each do |path|
  file = File.basename(path)
  before = @errors.length

  begin
    text = File.read(path, encoding: "UTF-8")
    data = load_yaml(text, file)
  rescue Psych::SyntaxError => e
    error(file, "YAML syntax error — this breaks the whole site build: #{e.message}")
  rescue Psych::DisallowedClass => e
    error(file, "disallowed YAML type: #{e.message}")
  rescue StandardError => e
    error(file, "could not read/parse: #{e.class}: #{e.message}")
  end
  if @errors.length > before
    puts "  FAIL  #{file}"
    next
  end

  if data.nil?
    puts "  OK    #{file} (empty)"
    next
  end

  if !data.is_a?(Array)
    error(file, "top level must be a list of `- key: value` entries, got #{data.class}")
  else
    case file
    when "publist.yml" then check_publist(file, data)
    when "news.yml" then check_news(file, data)
    else
      data.each_with_index do |entry, i|
        unless entry.is_a?(Hash)
          error(file, "entry #{i + 1}: expected a mapping, got #{entry.class}")
        end
      end
    end
  end

  puts(@errors.length == before ? "  OK    #{file}" : "  FAIL  #{file}")
end

puts
@warnings.each { |w| puts "WARNING: #{w}" }
@errors.each { |e| puts "ERROR: #{e}" }
puts "#{files.length} files checked: #{@errors.length} error(s), #{@warnings.length} warning(s)"
exit(@errors.empty? ? 0 : 1)
