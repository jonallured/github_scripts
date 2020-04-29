# frozen_string_literal: true

require 'yaml'
require 'octokit'

access_token = File.read('token.txt')
client = Octokit::Client.new(access_token: access_token)

# 30798 => Engineering team id
client.auto_paginate = true
logins = client.team_members('30798').map { |member| member['login'] }
client.auto_paginate = false

users = logins.map do |login|
  user = client.user(login)
  sliced = user.to_h.slice(:email, :name, :login)
  sliced[:username] = sliced.delete(:login)
  sliced
end

puts users.to_json
