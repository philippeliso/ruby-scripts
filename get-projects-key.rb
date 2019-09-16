#!/bin/ruby
require 'uri'
require 'net/https'
require 'json'


url = URI("https://bitbucket.intranet/rest/api/1.0/projects?limit=1000")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(url)
request["authorization"] = 'Bearer 0000000000' # svcacc_atlassian
request["cache-control"] = 'no-cache'

response = http.request(request)
# puts response.read_body

begin
 json = JSON.parse(response.read_body)
 # puts "json = #{json.inspect}"

 values = json["values"] # array contendo todos os values
 # puts "values = #{values.inspect}"

 project_key = values.select{|x| x["key"] } # array contendo todos os key de values
#  puts "project_key = #{project_keys.inspect}"

 keys = project_key.map{|x| x["key"] } # retorna array com todos as keys
 puts "Bitbucket Project Keys = #{keys.inspect}"

 # puts project_keys
rescue Exception => e
 puts "Erro no script, detalhe do erro: #{e.inspect}"
end

