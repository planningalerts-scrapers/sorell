require 'scraperwiki'
require 'rubygems'
require 'mechanize'

starting_url = 'http://www.sorell.tas.gov.au/publications/currently-advertised-applications/'

agent = Mechanize.new

# Grab the starting page and go into each link to get a more reliable data format.
doc = agent.get(starting_url)

doc.search('a').each do |url|
  next unless url[:href].to_s.match(/\.pdf/)

  council_ref = url.text.split(" - ").first
  representations_close = url.text.split(" - ").last.gsub(/Representations Close (Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday) /i, '').gsub(/(nd|st|rd|th)/i, '')
  representations_close_date = DateTime.strptime(representations_close, '%d %B %Y') rescue nil

  address = url.text.split(" - ")[1..-2].join(" - ")

  record = {
    'info_url' => url[:href].to_s,
    'comment_url' => 'mailto:sorell.council@sorell.tas.gov.au?subject=' + CGI::escape("Development Application Enquiry: " + council_ref),
    'council_reference' => council_ref,
    'on_notice_to' => representations_close_date,
    # 'date_received' => date_received,
    'address' => address,
    'description' => "Description not available. See 'Read more information' link.",
    'date_scraped' => Date.today.to_s
  }

  # puts record.inspect
  if (ScraperWiki.select("* from data where `council_reference`='#{record['council_reference']}'").empty? rescue true) 
    ScraperWiki.save_sqlite(['council_reference'], record)
    puts "Saving " + council_ref
  else
    puts "Skipping already saved record " + council_ref
  end
end
