#!/usr/bin/env ruby
# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require 'socket'

url = '10.10.136.108'
score = 0.0
path = '/'
next_port = 1337
retries = 0

loop do
  # Fetch and parse HTML document
  doc = Nokogiri::HTML(URI.open("http://#{url}:3010"))

  p port_init = doc.css('#onPort')[0].content.to_i
  break if port_init == next_port
  sleep 2
end

def parse_action(action, score)
  case action
  in ['add', value, port]
    score += value.to_f
    return port, score
  in ['minus', value, port]
    score -= value.to_f
    return port, score
  in ['divide', value, port]
    score /= value.to_f
    return port, score
  in ['multiply', value, port]
    score *= value.to_f
    return port, score
  in ['STOP']
    return nil, score
  end
end

until next_port.nil?
  begin
    s = TCPSocket.open(url, next_port)

    request = "GET #{path} HTTP/1.0\r\n\r\n"
    s.print(request)
    p response = s.read

    _headers, body = response.split("\r\n\r\n", 2)
    action = body.split(' ')

    next_port, score = parse_action(action, score)

    p score
  rescue Errno::ECONNREFUSED => e
    raise unless (retries += 1) <= 8

    puts "#{e}, retrying in 1 second..."
    sleep(1)
    retry
  ensure
    retries = 0
    s.close
  end
end

p score
