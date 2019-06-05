require 'yaml'
require 'fileutils'
require 'octokit'

access_token = File.read('token.txt')
client = Octokit::Client.new(access_token: access_token)

engineering_team_id = '30798'

client.auto_paginate = true
engineering_repos = client.team_repos engineering_team_id
artsy_repos = client.organization_repositories 'artsy'
client.auto_paginate = false

non_admin_repos = engineering_repos.reject { |repo| repo.permissions.admin }
missing_repos = artsy_repos.reject { |repo| client.team_repo?(engineering_team_id, repo.full_name) }

puts non_admin_repos.count
puts missing_repos.count

repos_to_add = non_admin_repos + missing_repos
repos_to_add.each do |repo|
  puts "setting Engineering as admin for #{repo.full_name}"
  client.add_team_repository(engineering_team_id, repo.full_name, permission: 'admin')
end
