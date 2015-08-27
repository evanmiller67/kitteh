require 'net/http'
require 'json'

module PageRefresh
  attr_accessor :channel, :aww
  
  def self.run(channel = @channel)
    @channel ||= channel  # Save this for later
    @aww ||= []
    @aww = get_urls if @aww.count <= 0
    sites = ["http://placekitten.com/{x}/{y}", 
             "http://lorempixel.com/{x}/{y}",
             "https://placeimg.com/{x}/{y}/animals",
             "http://place-hoff.com/{x}/{y}",
             "http://beerhold.it/{x}/{y}",
             "http://xoart.link/{x}/{y}/puppy",
             "http://xoart.link/{x}/{y}/kitten",
             "http://loremflickr.com/{x}/{y}/kitten",
             "http://loremflickr.com/{x}/{y}/puppy",
             "http://pipsum.com/{x}x{y}.jpg",
             "http://www.fillmurray.com/{x}/{y}",
             "http://www.placecage.com/{x}/{y}",
             "http://www.nicenicejpg.com/{x}/{y}",
             "http://baconmockup.com/{x}/{y}/",
             "awww"]
    site = sites.sample

    site = @aww.pop if site.eql? "awww"
    site = site.sub("{x}", "#{700+rand(500)}").sub("{y}", "#{400+rand(300)}")

    LOG.info "Sending URL '#{site}' to browsers"
    channel << site.force_encoding('UTF-8')
  end

  # Get pictures from reddit!
  # This should probably be cleaned up with some error handling
  def self.get_urls
    result = Net::HTTP.get(URI.parse('http://www.reddit.com/r/aww.json'))
    parsed = JSON.parse(result)

    urls = []
    for child in parsed["data"]["children"]
      urls.push child["data"]["url"]
    end
    urls
  end
end
