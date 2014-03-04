require 'spec_helper'
require 'yaml'
require_relative '../lib/net/webdav/client'


describe Net::Webdav::Client do
  config = YAML::load_file(File.join(File.dirname(File.expand_path(__FILE__)), 'config.yml'))
  url = config['url']
  path = config['path'] 
  full_url = [url, path].join
  username = config['username']
  password = config['password']
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

