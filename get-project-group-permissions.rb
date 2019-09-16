require 'uri'
require 'net/https'
require 'json'

url = URI("https://bitbucket.intranet/rest/api/1.0/projects?limit=10")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(url)
request["authorization"] = 'Bearer 0000000'
request["cache-control"] = 'no-cache'

response = http.request(request)

 json = JSON.parse(response.read_body)

 values = json["values"] # array contendo todos os values
 # puts "values = #{values.inspect}"

 project_key = values.select{|x| x["key"] } # array contendo todos os key de values
 # raise project_key.first.inspect

 consultas = project_key.map do |pk|
	key = pk["key"]
	#puts key

 	url = URI("https://bitbucket.intranet/rest/api/1.0/projects/#{key}/permissions/groups")

	 http = Net::HTTP.new(url.host, url.port)
	http.use_ssl = true
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE

	request = Net::HTTP::Get.new(url)
	request["authorization"] = 'Bearer 0000000000
	request["cache-control"] = 'no-cache'

	response = http.request(request)
 	
 	# file = File.open("json2.json")
 	json = JSON.parse(response.read_body)
 	# json = JSON.load(file)

 	resultado = json["values"].map do |value|
 		value["group"]["name"]
 	end

	resultado.uniq.flatten
 end
#  puts "project_key = #{project_keys.inspect}"
consultas.flatten.uniq.each {|x| puts x }
# puts consultas.flatten.inspect

 #keys = project_key.map{|x| x["key"] } # retorna array com todos as keys
 #puts "Bitbucket Project Keys = #{keys.inspect}"

 # puts project_keys
# rescue Exception => e
 # puts "Erro no script, detalhe do erro: #{e.inspect}"
# end