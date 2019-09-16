require 'uri'
require 'net/https'
require 'json'

url = URI("https://'bitbucket'.intranet/rest/api/1.0/projects?limit=999")

projects_http = Net::HTTP.new(url.host, url.port)
projects_http.use_ssl = true
projects_http.verify_mode = OpenSSL::SSL::VERIFY_NONE

projects_request = Net::HTTP::Get.new(url)
projects_request["authorization"] = 'Bearer 0000'
projects_request["cache-control"] = 'no-cache'

projects_response = projects_http.request(projects_request)
# puts response.read_body

resultados_finais = []

# begin
# file = File.open("json1.json")
projects_json = JSON.parse(projects_response.read_body)
 # json = JSON.load(file)


 projects_values = projects_json["values"] # array contendo todos os values
 # puts "values = #{values.inspect}"

 projects_keys = projects_values.select{|x| x["key"] } # array contendo todos os key de values
 # raise project_key.first.inspect

 groups_consultas = projects_keys.map do |pk|
	key = pk["key"]
	#puts key

 	groups_url = URI("https://bitbucket.intranet/rest/api/1.0/projects/#{key}/permissions/groups?limit=999")
    puts groups_url
    
	groups_http = Net::HTTP.new(groups_url.host, groups_url.port)
	groups_http.use_ssl = true
	groups_http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    groups_request = Net::HTTP::Get.new(groups_url)
	groups_request["authorization"] = 'Bearer 000000'
	groups_request["cache-control"] = 'no-cache'

    groups_response = groups_http.request(groups_request)
 
	# file = File.open("json2.json")
    groups_json = JSON.parse(groups_response.read_body)
		# json = JSON.load(file)

    groups_resultado = groups_json["values"].map do |value|
        [value["group"]["name"], value["permission"]]
    end

    uniq_groups = groups_resultado.uniq.flatten
    puts uniq_groups

####################################################################


	repos_url = URI("https://bitbucket.intranet/rest/api/1.0/projects/#{key}/repos?limit=999")
    puts repos_url

	repos_http = Net::HTTP.new(repos_url.host, repos_url.port)
	repos_http.use_ssl = true
	repos_http.verify_mode = OpenSSL::SSL::VERIFY_NONE

	repos_request = Net::HTTP::Get.new(repos_url)
	repos_request["authorization"] = 'Bearer 000000'
	repos_request["cache-control"] = 'no-cache'

	repos_response = repos_http.request(repos_request)

 	# file = File.open("json2.json")
 	repos_json = JSON.parse(repos_response.read_body)
 	# json = JSON.load(file)

     slugs_repo = repos_json["values"].map do |value|
        value["slug"]
    end

    uniq_slugs = slugs_repo.uniq.flatten

 ######################################################################

    slug_permissions = slugs_repo.map do |slug|


        slug_groups_url = URI("https://bitbucket.intranet/rest/api/1.0/projects/#{key}/repos/#{slug}/permissions/groups?limit=999")
        puts slug_groups_url

        slug_groups_http = Net::HTTP.new(slug_groups_url.host, slug_groups_url.port)
        slug_groups_http.use_ssl = true
        slug_groups_http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        slug_groups_request = Net::HTTP::Get.new(slug_groups_url)
        slug_groups_request["authorization"] = 'Bearer 0000000'
        slug_groups_request["cache-control"] = 'no-cache'

        slug_groups_response = slug_groups_http.request(slug_groups_request)

        # file = File.open("json2.json")
        slug_groups_json = JSON.parse(slug_groups_response.read_body)
        # json = JSON.load(file)

        slug_groups_resultado = slug_groups_json["values"].map do |value|
            value["group"]["name"]
        end

        permission_slug_groups_resultado_perm = slug_groups_json["values"].map do |value|
            value["permission"]
        end

        groups_names_uniq = slug_groups_resultado.flatten
        permission_groups_names_uniq = permission_slug_groups_resultado_perm.flatten

        puts groups_names_uniq        
        puts permission_groups_names_uniq
        
    end
    
 end
#  raise resultados_finais.inspect
# resultados_finais.map{|x| puts x}



#  puts "project_key = #{project_keys.inspect}"
# groups_consultas.flatten.uniq.each {|x| puts x }
# puts consultas.flatten.inspect

 #keys = project_key.map{|x| x["key"] } # retorna array com todos as keys
 #puts "Bitbucket Project Keys = #{keys.inspect}"

 # puts project_keys
# rescue Exception => e
 # puts "Erro no script, detalhe do erro: #{e.inspect}"
# end
