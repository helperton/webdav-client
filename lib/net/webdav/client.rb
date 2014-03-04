require 'uri'
require 'curb'


module Net
  module Webdav
    class Client
      attr_reader :host, :username, :password, :url, :http_auth_types

      def initialize url, options = {}
        scheme, userinfo, hostname, port, registry, path, opaque, query, fragment = URI.split(url)
        @host = "#{scheme}://#{hostname}#{port.nil? ? "" : ":" + port}"
        @http_auth_types = options[:http_auth_types] || :basic

        unless userinfo.nil?            
          @username, @password = userinfo.split(':')
        else
          @username = options[:username]
          @password = options[:password]
        end

        @url = URI.join(@host, path)
      end
      
      def file_exists? path
        response = Curl::Easy.http_head full_url(path)
        response.response_code >= 200 && response.response_code <= 209
      end
      
      def get_file remote_file_path, local_file_path
        Curl::Easy.download full_url(remote_file_path), local_file_path
      end

      def put_file path, file, create_path = true
        make_directory(path)
        curl = Curl::Easy.http_put full_url(path), file, &method(:auth)
        raise curl.status unless [201, 204, 301].include?(curl.response_code)
        curl 
      end

      def delete_file path
        Curl::Easy.http_delete full_url(path), &method(:auth)
      end

      def make_directory path
        scheme, userinfo, hostname, port, registry, path, opaque, query, fragment = URI.split(full_url(path))
        path_parts = path.split('/').reject {|s| s.nil? || s.empty?}
        extpath = Array.new
        path_parts.pop # take file name off the end
        path_parts.each do |part|
          parent_path = extpath.push(part).join("/")
          url = URI.join("#{scheme}://#{hostname}#{(port.nil? || port == 80) ? "" : ":" + port}/", parent_path)
          curl = Curl::Easy.new(full_url(url))
          auth(curl)
          curl.http(:MKCOL)
          curl
        end
      end
      
      private
      def auth curl
        curl.username = @username unless @username.nil?
        curl.password = @password unless @password.nil?
        curl.http_auth_types = @http_auth_types unless @http_auth_types.nil?
      end
      
      def full_url path
        URI.join(@url, path).to_s
      end
    end
  end
end
