require 'scraperwiki'
require 'rubygems'
require 'mechanize'

starting_url = 'http://www.sorell.tas.gov.au/publications/currently-advertised-applications/'

agent = Mechanize.new

# Grab the starting page and go into each link to get a more reliable data format.
doc = agent.get(starting_url)

doc.search('a').each do |url|
  next unless url[:href].to_s.match(/\.pdf/)
  next unless url[:href].to_s.downcase.include?("development-application")

  # Getting the council reference for this development application
  council_ref_array = url[:href].to_s.split("/").last.split("-").first.split(".")
  council_ref = council_ref_array[-2].to_s + "-" +council_ref_array[-1].to_s

  representations_close = url.text.split(" - ").last.gsub(/Representations Close (Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday) /i, '').gsub(/(nd|st|rd|th)/i, '')
  representations_close_date = DateTime.strptime(representations_close, '%d %B %Y') rescue nil

  address = ""
  application_found = false
  representations_found = false

  url_split = url.to_s.split("-")

  url_split.each do |a|
      if a.to_s.downcase == "representation" || a.to_s.downcase == "representations"
          representations_found = true
      end
      if application_found && !representations_found
          address += " " + a.to_s
      end
      if a.to_s.downcase == "application"
          application_found = true
      end
  end
  address = address.strip

  record = {
    'info_url' => url[:href].to_s,
    'comment_url' => 'mailto:sorell.council@sorell.tas.gov.au?subject=' + CGI::escape("Development Application Enquiry: " + council_ref),
    'council_reference' => council_ref,
    'on_notice_to' => representations_close_date,
    # 'date_received' => date_received,
    'address' => "#{address}, TAS",
    'description' => "Description not available. See 'Read more information' link.",
    'date_scraped' => Date.today.to_s
  }

  # puts record.inspect
  ScraperWiki.save_sqlite(['council_reference'], record)
  puts "Saving " + council_ref
end
