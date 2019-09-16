#!/bin/ruby
require 'uri'
require 'net/https'
require 'json'

perm_scope = ARGV[0] # users/groups
project = ARGV[1] # sigla do projeto

if perm_scope == "users"
	object_name = "user"
else
	object_name = "group"
end


url = URI("https://bitbucket.intranet/rest/api/1.0/projects/#{project}/permissions/#{perm_scope}?limit=50")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(url)
request["authorization"] = 'Bearer 0000000000000000' 
request["cache-control"] = 'no-cache'

response = http.request(request)
# puts response.read_body

begin
 json = JSON.parse(response.read_body)
 # puts "json = #{json.inspect}"

 values = json["values"] # array contendo todos os values
 # puts "values = #{values.inspect}"

 project_admins = values.select{|x| x["permission"] == "PROJECT_ADMIN"} # array contendo todos os values com permission = project_admin
 # puts "project_admins_groups = #{project_admins_groups.inspect}"

 admins = project_admins.map{|x| x["#{object_name}"]["name"] } # retorna array com todos os group names
 puts "#{object_name}_admins = #{admins.inspect}"

 # puts project_admins_groups
rescue Exception => e
 puts "Erro no script, detalhe do erro: #{e.inspect}"
end

