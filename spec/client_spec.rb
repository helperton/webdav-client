require 'spec_helper'
require_relative '../lib/net/webdav/client'


describe Net::Webdav::Client do
  url = 'https://attachments.navigatingcancer.com'
  path = 'navican-development/test1/test2/test3/cool.txt'
  full_url = [url, path].join
  username = 'navican'
  password = 'xYXNIaZSUVAVGxZHD'
  fd = IO.sysopen("file", "w+")
  io = IO.new(fd)
  io.write("yay!!\n")
  io.rewind

  w = Net::Webdav::Client.new(url, username: username, password: password)

  #w.make_directory(path) 
  w.put_file(path, io, true) 
  io.close
  File.unlink("file")
end

