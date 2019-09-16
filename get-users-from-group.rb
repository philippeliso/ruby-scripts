# ruby get-users-from-group.rb l-scrum-alcatraz prod|qa
# Get a list of users from a group validating if group exist and/if are empty or not printing they users when exist

require 'uri'
require 'net/https'
require 'json'

group = ARGV[0] # grupo
env = ARGV[1]   # Environment

if env == "prod"
    env_url = "bitbucket.intranet"
    access_key = "Bearer 0000000000"
else
    env_url = "bitbucket.qa.intranet"
    access_key = "Bearer 11111111111111111111"
end


groups_url = URI("https://#{env_url}/rest/api/1.0/admin/groups?filter=#{group}")

groups_http = Net::HTTP.new(groups_url.host, groups_url.port)
groups_http.use_ssl = true
groups_http.verify_mode = OpenSSL::SSL::VERIFY_NONE
groups_request = Net::HTTP::Get.new(groups_url)
groups_request["authorization"] = "#{access_key}" # svcacc_atlassian
groups_request["cache-control"] = 'no-cache'
groups_response = groups_http.request(groups_request)

groups_json = JSON.parse(groups_response.read_body)
groups_resultado = groups_json["values"].map do |value|
    value["name"]
end

uniq_groups = groups_resultado.uniq.flatten



###########################################################################
if (groups_resultado.empty?)
    puts "Environment: #{env_url}"
    puts "Group #{group} not found",""
else
    group_members_url = URI("https://#{env_url}/rest/api/1.0/admin/groups/more-members?context=#{group}&limit=999")
    puts "Environment: #{env_url}"

    group_members_http = Net::HTTP.new(group_members_url.host, group_members_url.port)
    group_members_http.use_ssl = true
    group_members_http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    group_members_request = Net::HTTP::Get.new(group_members_url)
    group_members_request["authorization"] = "#{access_key}" # svcacc_atlassian
    group_members_request["cache-control"] = 'no-cache'
    group_members_response = group_members_http.request(group_members_request)

    group_members_json = JSON.parse(group_members_response.read_body)
    group_members_resultado = group_members_json["values"].map do |value|
        value["name"]
    end

    uniq_group_members = group_members_resultado.uniq.flatten
    # puts uniq_group_members
    # puts 
    if (group_members_resultado.empty?)
        puts "Group #{group} present but without users",""
    else
        # puts "Members of #{group}: #{uniq_group_members}",""
        puts uniq_group_members
    end
end

