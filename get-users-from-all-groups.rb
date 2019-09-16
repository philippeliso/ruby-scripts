require 'uri'
require 'net/https'
require 'json'

url = URI("https://bitbucket.intranet/rest/api/1.0/admin/groups?limit=5000")
# puts url

projects_http = Net::HTTP.new(url.host, url.port)
projects_http.use_ssl = true
projects_http.verify_mode = OpenSSL::SSL::VERIFY_NONE
projects_request = Net::HTTP::Get.new(url)
projects_request["authorization"] = 'Bearer 0000000000' # svcacc_atlassian
projects_request["cache-control"] = 'no-cache'
projects_response = projects_http.request(projects_request)
# puts response.read_body

projects_json = JSON.parse(projects_response.read_body)
projects_values = projects_json["values"] # array contendo todos os values
projects_keys = projects_values.select{|x| x["name"] } # array contendo todos os key de values

groups_consultas = projects_keys.map do |pk|
key = pk["name"]
# puts key

    groups_url = URI("https://bitbucket.intranet/rest/api/1.0/admin/groups/more-members?context=#{key}&limit=100")
    # puts groups_url
    puts "Grupo: #{key}"
    
	groups_http = Net::HTTP.new(groups_url.host, groups_url.port)
	groups_http.use_ssl = true
	groups_http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    groups_request = Net::HTTP::Get.new(groups_url)
	groups_request["authorization"] = 'Bearer 0000000000' # svcacc_atlassian
	groups_request["cache-control"] = 'no-cache'
    groups_response = groups_http.request(groups_request)
 
    groups_json = JSON.parse(groups_response.read_body)

    groups_resultado = groups_json["values"].map do |value|
        value["name"]
    end

    uniq_groups = groups_resultado.uniq.flatten
    puts "Members: #{uniq_groups}",""
    # puts uniq_groups

 end

