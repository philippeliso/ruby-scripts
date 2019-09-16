#!/bin/ruby
require 'uri'
require 'net/https'
require 'json'

# Get license info
url = URI("https://bitubkcet.intranet/rest/api/1.0/admin/license")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(url)
request["authorization"] = 'Bearer someaccess-key'
request["cache-control"] = 'no-cache'

response = http.request(request)
licensed_users = JSON.parse(response.read_body)["status"]["currentNumberOfUsers"]
max_licensed_users = JSON.parse(response.read_body)["maximumNumberOfUsers"]
available_licensed_users = max_licensed_users - licensed_users

# Post so slack channel #sistemas-base-monit
def post_slack available_licenses

    proxy_addr = 'proxy-corp-apps.intranet'
    proxy_port = 80

    url = URI("https://hooks.slack.com/services/..../.../xxxxxxxxx")

    http = Net::HTTP.new(url.host, url.port, proxy_addr, proxy_port)
	http.use_ssl = true
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    if available_licenses <=50
    	priority = 'danger'
    else
    	priority = 'warning'    	
    end

	request = Net::HTTP::Post.new(url)
	request["content-type"] = 'application/json'
	request["cache-control"] = 'no-cache'
	request.body = "{\n\n   
						\"channel\":\"#sistemas-base-monit\",\n   
						\"username\":\"Bitbucket Alert\",\n   
						\"icon_url\":\"https://avatars.slack-edge.com/2018-12-05/00000_0000_0.png\",\n    
						\"attachments\": [\n        
							{\n            
								\"fallback\": \"Licenças disponíveis\",\n            
								\"pretext\": \"Bitbucket\",\n            
								\"title\": \"Licenças disponíveis\",\n            
								\"text\": \"<!channel> Atualmente temos #{available_licenses} licenças disponíveis\",\n            
								\"color\": \"#{priority}\"\n        
							}\n    
						]\n
					}"

	response = http.request(request)
end

post_slack available_licensed_users if available_licensed_users <= 100
