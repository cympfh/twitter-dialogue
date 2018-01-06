#!/usr/bin/env ruby

require 'json'

#
# args
#

name = ARGV[0]

last_id_path = "#{name}.last"
last_id = if File.exist?(last_id_path)
            open(last_id_path, "r") do |f|
              f.read.to_i
            end
          else
            0
          end

#
# helpers
#
def json_parse(s)
  JSON.parse(s, {:symbolize_names => true})
end

def as_quote(text)
  # Format: "brabrabra RT @id hogehogehoge"
  p = /^(.*) RT @[0-9a-zA-Z_]* (.*)$/
  result = p.match(text)
  if result
    result.captures
  else
    nil
  end
end

def get_timeline(name)
  out = "/tmp/timeline-#{name}.json"
  `twurl "/1.1/statuses/user_timeline.json?screen_name=#{name}&count=200&include_rts=false" > #{out}`
  out
end

def get_status(id)
  json_parse `twurl "/1.1/statuses/show.json?id=#{id}"`
end

def report(item, pair)
  # pair = [reply, target]
  created_at = item[:created_at]
  text = item[:text]
  obj = {
    :created_at => created_at,
    :text => text,
    :a => pair[0],
    :b => pair[1]
  }
  puts JSON.dump obj
end

#
# get timeline
#
STDERR.puts "get #{name} from #{last_id}"
json_path = get_timeline(name)

#
# parse
#
timeline = json_parse open(json_path, "r").read
timeline.reverse.each do |item|

  id_str = item[:id_str]
  if id_str.to_i <= last_id
    next
  end

  text = item[:text]

  in_reply_to_status_id_str = item[:in_reply_to_status_id_str]
  if in_reply_to_status_id_str
    src = get_status(in_reply_to_status_id_str)[:text]
    report(item, [text, src])
  end

  pair = as_quote text
  if pair
    report(item, pair)
    next
  end

end

File.open(last_id_path, "w") do |f|
  f.write timeline[0][:id_str]
end
