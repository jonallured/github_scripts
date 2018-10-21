require 'yaml'
require 'octokit'

class Checker
  def self.send_keys
    command = "tmux send-keys -t volt:0.0 'rake; jay done' Enter"
    system(command)
  end

  def initialize(client)
    @client = client
    @build_events = Set.new
    @found_new = false
  end

  def check
    @found_new = false
    events = @client.repository_events("jonallured/volt")

    create_tag_events = events.select do |event|
      event.type == "CreateEvent" &&
        event.payload.ref_type == "tag" &&
        event.payload.ref == "colossus-build-me"
    end

    results = create_tag_events.map do |event|
      result = @build_events.add?(event.id)
      !!result
    end

    @found_new = results.uniq.include?(true)
  end

  def found_new?
    @found_new
  end
end

access_token = File.read('token.txt')
client = Octokit::Client.new(access_token: access_token)
checker = Checker.new(client)

loop do
  puts "checking..."
  checker.check
  if checker.found_new?
    puts "sending keys..."
    Checker.send_keys
  end
  puts "sleeping..."
  puts ?**80
  sleep 10
end

puts volt_tag_events.map(&:to_hash)
