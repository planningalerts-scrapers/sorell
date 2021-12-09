require 'scraperwiki'
require 'mechanize'

def scrape()
  starting_url = 'http://www.sorell.tas.gov.au/publications/currently-advertised-applications/'

  agent = Mechanize.new

  if ENV["MORPH_AUSTRALIAN_PROXY"]
    # On morph.io set the environment variable MORPH_AUSTRALIAN_PROXY to
    agent.agent.set_proxy(ENV["MORPH_AUSTRALIAN_PROXY"])
  end

  agent.verify_mode = OpenSSL::SSL::VERIFY_NONE

  # Grab the starting page and go into each link to get a more reliable data format.
  doc = agent.get(starting_url)

  doc.search('a').each do |url|
    next unless url[:href].to_s.match(/\.pdf/)
    next unless url[:href].to_s.downcase.include?("development-application")
    puts url[:href]
    council_ref_array = url[:href].to_s.split("/").last.split("-").first.split(".")
    council_ref = council_ref_array[-2].to_s + "-" +council_ref_array[-1].to_s
    representations_close = url.text.split(" - ").last.gsub(/Representations Close (Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday) /i, '').gsub(/(nd|st|rd|th)/i, '')
    representations_close_date = DateTime.strptime(representations_close, '%d %B %Y') rescue nil

    address = get_address_from_url(url[:href])

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
    puts "Saving " + council_ref.strip()
  end
end


def get_address_from_url(url)
  address = ""
  application_found = false
  representations_found = false

  url_split = url.to_s.split("-")

  url_split.each do |a|
      if a.to_s.downcase == "application"
          application_found = true
      end
      if a.to_s.downcase == "representation" || a.to_s.downcase == "representations"
          representations_found = true
      end

      if application_found && !representations_found
          if a.to_s.downcase != "application"
              address += " " + a.to_s
          end
      end
  end
  address = address.strip
  address
end


scrape()