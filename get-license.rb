#!/bin/ruby
require 'uri'
require 'net/https'
require 'json'

url = URI("https://bitbucket.intranet/rest/api/1.0/admin/license")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(url)
request["authorization"] = 'Bearer 00000000000000000000000'
request["cache-control"] = 'no-cache'

response = http.request(request)
expiry = JSON.parse(response.read_body)["numberOfDaysBeforeExpiry"]
current = JSON.parse(response.read_body)["status"]["currentNumberOfUsers"]

puts "#{expiry} #{current}"