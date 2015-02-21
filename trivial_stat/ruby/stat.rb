#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'jubatus/stat/client'

$host = "127.0.0.1"
$port = 9199
$name = "stat_tri"

if $0 == __FILE__
  # 1. Connection Config
  stat = Jubatus::Stat::Client::Stat.new($host, $port, $name)

  # 2. Prepare training data
  File.read('../dat/fruit.csv').each_line do |line|
    fruit, diameter, weight, price = line.split(',')

    # 3. Train
    stat.push("#{fruit}dia", diameter.to_f)
    stat.push("#{fruit}wei", weight.to_f)
    stat.push("#{fruit}pri", price.to_f)
  end

  # 4. Output result
  ['orange', 'apple', 'melon'].each do |fr|
    ['dia', 'wei', 'pri'].each do |par|
      fr_par = "#{fr}#{par}"
      puts "sum : #{fr_par} #{stat.sum(fr_par)}"
      puts "sdv : #{fr_par} #{stat.stddev(fr_par)}"
      puts "max : #{fr_par} #{stat.max(fr_par)}"
      puts "min : #{fr_par} #{stat.min(fr_par)}"
      puts "ent : #{fr_par} #{stat.entropy(fr_par)}"
      puts "mmt : #{fr_par} #{stat.moment(fr_par, 1, 0.0)}"
      puts
    end
  end
end
