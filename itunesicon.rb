#!/usr/bin/ruby
# encoding: utf-8
#
# Updated 2017-10-25:
# - Defaults to large size (512)
# - If ImageMagick is installed:
#     - rounds the corners (copped from @bradjasper, https://github.com/bradjasper/Download-iTunes-Icon/blob/master/itunesicon.rb)
#     - replace original with rounded version, converting to png if necessary
# 
# Retrieve an iOS app icon at the highest available resolution
# All arguments are combined to create an iTunes search
# The icon for the first result, if found, is written to a filename
# based on search terms
#
# If ImageMagick is installed (available through Homebrew), rounded
# corners will be added and a transparent PNG will be output.
#
# example:
# $ itunesicon super monsters ate my condo
#
# Use size param ~s/~small/~m/~medium/~l/~large to specify size:
# $ itunesicon super monsters ate my condo ~small 
# 
# http://brettterpstra.com/2013/04/28/instantly-grab-a-high-res-icon-for-any-ios-app/
# http://brettterpstra.com/2013/12/18/icon-grabber-updated-to-search-any-platform/

%w[net/http open-uri cgi fileutils].each do |filename|
  require filename
end
require 'open-uri' 

def find_icon(terms, format)
  # url = URI.parse("http://itunes.apple.com/search?term=#{CGI.escape(terms)}&entity=#{entity}")
  url = URI.parse("http://itunes.apple.com/lookup?id=#{terms}&country=cn")
  # puts url
  # res = Net::HTTP.get_response(url).body
  res = open(url).read
  match = res.match(/"#{format}":"(.*?)",/)
  unless match.nil?
    return match[1]
  else
    return false
  end
end

terms = ARGV[0]

format = "artworkUrl512"
size = "l"

icon_url = find_icon(terms, format)
puts icon_url
unless icon_url
  puts "Error: failed to locate iTunes url. You may need to adjust your search terms."
  exit
end
url = URI.parse(icon_url)
target = File.expand_path("./"+terms.gsub(/[^a-z0-9]+/i,'_')+"_"+size+"."+icon_url.match(/\.(jpg|png)$/)[1])
begin
  open(url) do |f|
    File.open(target,'w+') do |file|
      file.puts f.read
    end    
  end
rescue Exception => e
  # puts e.backtrace
  # p e
  puts "Error: failed to save icon."
end
