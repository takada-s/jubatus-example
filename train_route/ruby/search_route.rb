#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'json'

require 'jubatus/graph/client'

$host = "127.0.0.1"
$port = 9199
$name = "test"


def search_route(from_id, to_id)
  c = Jubatus::Graph::Client::Graph.new($host, $port, $name)

  pq       = Jubatus::Graph::PresetQuery.new([], [])
  spreq    = Jubatus::Graph::ShortestPathQuery.new(from_id, to_id, 100, pq)
  stations = c.get_shortest_path(spreq)

  puts "Pseudo-Shortest Path (hops) from #{from_id} to #{to_id}"
  stations.each do |station|
    node = c.get_node(station)
    station_name = ''
    if node.property.include? 'name'
      station_name = node.property['name']
    end
    puts "  #{station}\t#{station_name}"
  end

end


if $0 == __FILE__
  if ARGV.length < 2
    STDERR.puts "Usage: #{$0} from_station_id to_station_id"
    exit 1
  end

  search_route(ARGV[0].to_s, ARGV[1].to_s)
end
