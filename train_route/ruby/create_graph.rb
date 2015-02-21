#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rexml/document'
require 'open-uri'

require 'jubatus/graph/client'

$host = "127.0.0.1"
$port = 9199
$name = "test"

$stations = {}

StationJoin = Struct.new(:station1, :station2)


# Create array of StationJoin Struct, represents which stations are connected.
#
# @param [string] line_cd: target line-code
# @return [Array] array of StationJoin Struct
def get_station_join(line_cd)
  join_list = []
  url = "http://www.ekidata.jp/api/n/#{line_cd}.xml"
  xml = REXML::Document.new(open(url))

  xml.elements.each('ekidata/station_join') do |join_info|
    station_name1 = join_info.elements['station_name1'].text
    station_name2 = join_info.elements['station_name2'].text
    station_join = StationJoin.new(station_name1, station_name2)
    join_list << station_join
  end

  join_list
end

def create_graph(c, join_list)
  join_list.each do |join|
    # Create nodes for stations.
    s1_node_id = add_station(c, join.station1)
    s2_node_id = add_station(c, join.station2)

    # Create bi-directional edge between two nodes.
    edge_1 = Jubatus::Graph::Edge.new({}, s1_node_id, s2_node_id)
    edge_2 = Jubatus::Graph::Edge.new({}, s2_node_id, s1_node_id)
    c.create_edge(s1_node_id, edge_1)
    c.create_edge(s2_node_id, edge_2)

    # Comment-out this line if you're running in distributed mode.
    c.update_index
  end
end

def add_station(c, name)
  if $stations.include? name
    node_id = $stations[name]
  else
    node_id = c.create_node
    c.update_node(node_id, {'name' => name})
    $stations[name] = node_id
  end
  node_id
end

def print_stations
  $stations.sort_by{|sta|
    sta[1].to_i
  }.each{|name, id|
    puts "#{id}\t#{name}"
  }
end

if $0 == __FILE__
  # create jubagraph client.
  c = Jubatus::Graph::Client::Graph.new($host, $port, $name)

  # Prepare query
  pq = Jubatus::Graph::PresetQuery.new([], [])
  c.add_shortest_path_query(pq)

  create_graph(c, get_station_join(11302)) # 山手線
  create_graph(c, get_station_join(11312)) # 中央線

  puts '=== Station IDs ==='
  print_stations
end
