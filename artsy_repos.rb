require 'yaml'
require 'octokit'

access_token = File.read('token.txt')
client = Octokit::Client.new(access_token: access_token)

client.auto_paginate = true
repos = client.organization_repositories 'artsy'
client.auto_paginate = false

origin_repos = repos.reject(&:fork)
repo_names = origin_repos.map(&:name).sort
repo_hashes = repo_names.map { |name| { 'id' => name } }
puts repo_hashes.to_yaml
