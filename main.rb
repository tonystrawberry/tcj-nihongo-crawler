# frozen_string_literal: true

crawling_target = ARGV[0]

if crawling_target.nil?
  puts '[ERROR] Please provide a crawling target as an argument (e.g. `tcj_nihongo`)'
  exit
end

case crawling_target.to_sym
when :tcj_nihongo
  require_relative 'crawlers/tcj_nihongo'

  crawler = Crawlers::TcjNihongo.new
  crawler.crawl
else
  puts "[ERROR] Invalid crawling target: #{crawling_target}"
end
