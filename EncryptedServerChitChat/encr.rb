#!/usr/bin/env ruby
# frozen_string_literal: true

require 'openssl'
require 'digest'
require 'socket'

url = '10.10.81.121'
port = 4000
BUFFER = 10_000

u1 = UDPSocket.new
u1.send 'hello', 0, url, port
text, _addr = u1.recvfrom(BUFFER)
p text

u1.send 'ready', 0, url, port
text, _addr = u1.recvfrom(BUFFER)
p text

p key = text[4...28]
p iv = text[32...44]

p hash = text[104...136].unpack1('H*')

decrypted = ''
while Digest::SHA2.hexdigest(decrypted) != hash
  u1.send 'final', 0, url, port
  encrypted, _addr = u1.recvfrom(BUFFER)
  p text

  u1.send 'final', 0, url, port
  tag, _addr = u1.recvfrom(BUFFER)
  p tag

  decipher = OpenSSL::Cipher::AES.new(key.bytesize * 8, :GCM).decrypt
  decipher.key = key
  decipher.iv = iv
  decipher.auth_tag = tag

  decrypted = decipher.update(encrypted) + decipher.final

end

puts decrypted
