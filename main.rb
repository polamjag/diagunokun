# -*- coding: utf-8 -*-
require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'
require 'resolv'

INFO_TO_DISPLAY = %w{
  REMOTE_ADDR REMOTE_HOST REQUEST_METHOD REQUEST_URI
  SERVER_PROTOCOL SERVER_NAME SERVER_PORT
  HTTP_HOST HTTP_CONNECTION HTTP_CACHE_CONTROL
  HTTP_ACCEPT HTTP_ACCEPT_ENCODING HTTP_ACCEPT_LANGUAGE HTTP_DNT HTTP_USER_AGENT
  HTTP_X_FORWARDED_FOR HTTP_X_REAL_IP
}

def safe_getname(ipaddr, is_format_embedded = true)
  unless ipaddr.nil? || ipaddr.empty?
    if is_format_embedded
      "#{ipaddr} (#{Resolv.getname ipaddr})"
    else
      Resolv.getname ipaddr
    end
  else
    ""
  end
end

get '/' do
  @info = INFO_TO_DISPLAY.map do |i|
    [i, Rack::Utils.escape_html(@env[i])]
  end
  @info = Hash[*@info.flatten]
  @info['HTTP_X_FORWARDED_FOR'] = safe_getname @info['HTTP_X_FORWARDED_FOR'], true
  @info['HTTP_X_REAL_IP']       = safe_getname @info['HTTP_X_REAL_IP'], true
  @info = @info.map do |k, v|
    "<dt>#{k}</dt><dd>#{v}</dd>"
  end
  @info = @info.join "\n        " # workaround for correct indent
  erb :index
end

get '/json' do
  content_type 'application/json'
  @info = INFO_TO_DISPLAY.map do |i|
    [i, @env[i]]
  end
  @info.push ['HTTP_X_FORWARDED_FOR_NAME', safe_getname(@env['HTTP_X_FORWARDED_FOR'], false)]
  @info.push ['HTTP_X_REAL_IP_NAME', safe_getname(@env['HTTP_X_REAL_IP'], false)]
  Hash[*@info.flatten].to_json
end

get '/csv' do
  content_type 'text/plain'
  @info = INFO_TO_DISPLAY.map { |i|
    "\"#{i}\",\"#{@env[i]}\"\r\n"
  }
  @info.push "\"HTTP_X_FORWARDED_FOR_NAME\",\"#{safe_getname @env['HTTP_X_FORWARDED_FOR'], false}\"\r\n"
  @info.push "\"HTTP_X_REAL_IP_NAME\",\"#{safe_getname @env['HTTP_X_REAL_IP'], false}\"\r\n"
  @info.join
end

