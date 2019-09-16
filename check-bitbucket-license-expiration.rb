#!/bin/ruby
require 'uri'
require 'net/https'
require 'json'

# Get license info
url = URI("https://bitbucket.intranet/rest/api/1.0/admin/license")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(url)
request["authorization"] = 'Bearer someaccess-key'
request["cache-control"] = 'no-cache'

response = http.request(request)
days_toexpire = JSON.parse(response.read_body)["numberOfDaysBeforeExpiry"]

# Post to slack channel #sistemas-base-monit
def post_slack expire

    proxy_addr = 'proxy-corp-apps.intranet'
    proxy_port = 80

    url = URI("https://hooks.slack.com/services/..../.../xxxxxxxxx")

    http = Net::HTTP.new(url.host, url.port, proxy_addr, proxy_port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

#    if expire <=300 # para testar
    if expire <=30
    	priority = 'danger'
        puts priority
    else
    	priority = 'warning'
        puts priority    	
    end

    request = Net::HTTP::Post.new(url)
    request["content-type"] = 'application/json'
    request["cache-control"] = 'no-cache'
    request.body = "{\n\n   
	                    \"channel\":\"#adm-sistemas-base\",\n   
	                    \"username\":\"Bitbucket Alert\",\n   
	                    \"icon_url\":\"https://avatars.slack-edge.com/2018-12-05/0000_000_0.png\",\n    
	                    \"attachments\": [\n        
	                        {\n            
                                \"fallback\": \"Dias para expiração de licença\",\n            
                                \"pretext\": \"Bitbucket\",\n            
                                \"title\": \"Dias para expiração de licença\",\n            
                                \"text\": \"<!channel> Faltam #{expire} dias para que a licença do Bitbucket seja expirada. Entrar em contato com o time de compras para solicitar a renovação.\",\n            
                                \"color\": \"#{priority}\"\n        
	                        }\n    
	                    ]\n
                    }"

    response = http.request(request)
end
# post_slack days_toexpire if days_toexpire <= 400 # para testar
post_slack days_toexpire if days_toexpire <= 60
