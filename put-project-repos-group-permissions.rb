# ruby put-project-repos-group-permissions.rb qa|production
require 'uri'
require 'net/https'
require 'json'

env = ARGV[0]   # Environment

if env == "production"
    @env_url = "bitbucket.intranet"
    @access_key = "Bearer 0000000000"
else
    @env_url = "bitbucket.qa.intranet"
    @access_key = "Bearer 1111111111"
end

### Get all project keys
projects_url = URI("https://#{@env_url}/rest/api/1.0/projects?limit=999")

projects_http = Net::HTTP.new(projects_url.host, projects_url.port)
projects_http.use_ssl = true
projects_http.verify_mode = OpenSSL::SSL::VERIFY_NONE
projects_request = Net::HTTP::Get.new(projects_url)
projects_request["authorization"] = "#{@access_key}" # svcacc_atlassian
projects_request["cache-control"] = 'no-cache'

projects_response = projects_http.request(projects_request)
projects_json = JSON.parse(projects_response.read_body)
 
projects_values = projects_json["values"] # array contendo todos os values
# puts "projects_values = #{values.inspect}"

projects_keys = projects_values.select{|x| x["key"] } # array contendo todos os key de values (Todas as project keys)
# raise project_key.first.inspect

#########################################################################################################################################################

def update_project_group_names(project_key, project_group_name, project_permission)
            
    put_slug_groups_url = URI("https://#{@env_url}/rest/api/1.0/projects/#{project_key}/permissions/groups?name=#{project_group_name}&permission=#{project_permission}")
    puts put_slug_groups_url
    
    put_slug_groups_http = Net::HTTP.new(put_slug_groups_url.host, put_slug_groups_url.port)
    put_slug_groups_http.use_ssl = true
    put_slug_groups_http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    put_slug_groups_request = Net::HTTP::Put.new(put_slug_groups_url)
    put_slug_groups_request["authorization"] = "#{@access_key}" # svcacc_atlassian
    put_slug_groups_request["cache-control"] = 'no-cache'
    put_slug_groups_request["Content-Type"] = 'application/json'

    put_slug_groups_response = put_slug_groups_http.request(put_slug_groups_request)
    puts "PROJETO: #{project_key}, GRUPO: #{project_group_name}, PERMISSAO: #{project_permission}, STATUS: #{put_slug_groups_response.code}"
end

def update_slug_group_names(project_key, repo_slug, slug_group_name, slug_group_permission)
    
    put_slug_groups_url = URI("https://#{@env_url}/rest/api/1.0/projects/#{project_key}/repos/#{repo_slug}/permissions/groups?name=#{slug_group_name}&permission=#{slug_group_permission}")
    puts put_slug_groups_url
    
    put_slug_groups_http = Net::HTTP.new(put_slug_groups_url.host, put_slug_groups_url.port)
    put_slug_groups_http.use_ssl = true
    put_slug_groups_http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    put_slug_groups_request = Net::HTTP::Put.new(put_slug_groups_url)
    put_slug_groups_request["authorization"] = "#{@access_key}" # svcacc_atlassian
    put_slug_groups_request["cache-control"] = 'no-cache'
    put_slug_groups_request["Content-Type"] = 'application/json'

    put_slug_groups_response = put_slug_groups_http.request(put_slug_groups_request)
    puts "PROJETO: #{project_key}, REPOSITORIO: #{repo_slug}, GRUPO: #{slug_group_name}, PERMISSAO: #{slug_group_permission}, STATUS: #{put_slug_groups_response.code}"
end

### Get all permission groups of Project and Post new permission groups
    projects_keys.map do |pk|
        key = pk["key"]
        #puts key

        groups_url = URI("https://#{@env_url}/rest/api/1.0/projects/#{key}/permissions/groups?limit=999")
        puts groups_url
        
        groups_http = Net::HTTP.new(groups_url.host, groups_url.port)
        groups_http.use_ssl = true
        groups_http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        groups_request = Net::HTTP::Get.new(groups_url)
        groups_request["authorization"] = "#{@access_key}" # svcacc_atlassian
        groups_request["cache-control"] = 'no-cache'

        groups_response = groups_http.request(groups_request)
        groups_json = JSON.parse(groups_response.read_body)

        groups_json["values"].each do |value|
            if value["group"]["name"].match(/^l-scrum-/)
                new_group = value["group"]["name"].gsub(/^l-scrum-/, "G_s_p_scrum-") + "_X"
                update_project_group_names(key, new_group, value["permission"])
            elsif !value["group"]["name"].match(/^[gG]_s_p_scrum-/) # primeira letra ficou minuscula, ???
                puts "Grupos sem match #{value["group"]["name"]}"
            end             
        end
        

#########################################################################################################################################################

### Get all repositories of all projects
        repos_url = URI("https://#{@env_url}/rest/api/1.0/projects/#{key}/repos?limit=999")
        puts repos_url

        repos_http = Net::HTTP.new(repos_url.host, repos_url.port)
        repos_http.use_ssl = true
        repos_http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        repos_request = Net::HTTP::Get.new(repos_url)
        repos_request["authorization"] = "#{@access_key}" # svcacc_atlassian
        repos_request["cache-control"] = 'no-cache'

        repos_response = repos_http.request(repos_request)
        repos_json = JSON.parse(repos_response.read_body)

        slugs_repo = repos_json["values"].map do |value|
            value["slug"]
        end

 #########################################################################################################################################################

 ### Get all groupos permission of repositories of all projects

        slug_permissions = slugs_repo.map do |slug|

        slug_groups_url = URI("https://#{@env_url}/rest/api/1.0/projects/#{key}/repos/#{slug}/permissions/groups?limit=999")
        puts slug_groups_url

        slug_groups_http = Net::HTTP.new(slug_groups_url.host, slug_groups_url.port)
        slug_groups_http.use_ssl = true
        slug_groups_http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        slug_groups_request = Net::HTTP::Get.new(slug_groups_url)
        slug_groups_request["authorization"] = "#{@access_key}" # svcacc_atlassian
        slug_groups_request["cache-control"] = 'no-cache'

        slug_groups_response = slug_groups_http.request(slug_groups_request)
        slug_groups_json = JSON.parse(slug_groups_response.read_body)
    
        slug_groups_json["values"].each do |value|
            if value["group"]["name"].match(/^l-scrum-/)
                new_slug_group_name = value["group"]["name"].gsub(/^l-scrum-/, "G_s_p_scrum-") + "_X"
                update_slug_group_names(key, slug, new_slug_group_name, value["permission"])
            elsif !value["group"]["name"].match(/^[gG]_s_p_scrum-/) # primeira letra ficou minuscula, ???
                puts "Grupos sem match #{value["group"]["name"]}"
            end 
        end
    end
end
