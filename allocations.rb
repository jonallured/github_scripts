require 'yaml'
require 'fileutils'
require 'octokit'

puts "this script is defunct and i'm not going to fix it because we don't do allocations like we used to at Artsy"
exit 1

if ARGV.first == nil
  puts "run like this:"
  puts "  $ ruby script.rb 2017-01"
  exit 1
end

FileUtils.mkdir_p('reports')

date = Date.parse "#{ARGV.first}-01"

credentials = YAML.load File.read 'credentials.yml'
client = Octokit::Client.new(login: credentials['login'], password: credentials['password'])

client.auto_paginate = true
repos = client.organization_repositories 'artsy'
client.auto_paginate = false

results = {}

for repo in repos
  full_name = repo.full_name
  all_pulls = client.pulls full_name, state: :all, per_page: 100
  my_pulls = all_pulls.select do |pull|
    my_pull = pull.user.login == credentials['login']
    created_at = pull.created_at
    this_month = created_at.month == date.month && created_at.year == date.year
    my_pull && this_month
  end

  if my_pulls.count > 0
    results[full_name] = my_pulls
    print ?!
  else
    print ?.
  end
end

puts "\n"

pretty_date = date.strftime('%Y-%m')

File.open("reports/report-#{pretty_date}.md", 'w') do |f|
  f.puts "# Report for #{pretty_date}"
  for full_name, pulls in results
    puts "#{full_name} => #{pulls.count}"
    f.puts "\n## #{full_name}\n\n"
    for pull in pulls
      f.puts "* [#{pull.title}](#{pull.html_url}) - #{pull.state}"
    end
  end
end
