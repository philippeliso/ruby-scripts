# ruby get-groups.rb

require 'uri'
require 'net/https'
require 'json'

groups_url = URI("https://bitbucket.intranet/rest/api/1.0/admin/groups?limit=5000")

groups_http = Net::HTTP.new(groups_url.host, groups_url.port)
groups_http.use_ssl = true
groups_http.verify_mode = OpenSSL::SSL::VERIFY_NONE
groups_request = Net::HTTP::Get.new(groups_url)
groups_request["authorization"] = 'Bearer 00000000000000000000000'
groups_request["cache-control"] = 'no-cache'
groups_response = groups_http.request(groups_request)

groups_json = JSON.parse(groups_response.read_body)
groups_resultado = groups_json["values"].map do |value|
    value["name"]
end

uniq_groups = groups_resultado.uniq.flatten
puts uniq_groups


