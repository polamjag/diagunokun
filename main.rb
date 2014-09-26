# -*- coding: utf-8 -*-
require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'

INFO_TO_DISPLAY = %w{
  REMOTE_ADDR REMOTE_HOST REQUEST_METHOD REQUEST_URI
  SERVER_PROTOCOL SERVER_NAME SERVER_PORT
  HTTP_HOST HTTP_CONNECTION HTTP_CACHE_CONTROL
  HTTP_ACCEPT HTTP_ACCEPT_ENCODING HTTP_ACCEPT_LANGUAGE HTTP_DNT HTTP_USER_AGENT
  HTTP_X_FORWARDED_FOR HTTP_X_REAL_IP
}

get '/' do
  @info = INFO_TO_DISPLAY.map do |i|
    [i, Rack::Utils.escape_html(@env[i])]
  end
  @info = Hash[*@info.flatten]
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
  Hash[*@info.flatten].to_json
end

get '/csv' do
  content_type 'text/plain'
  INFO_TO_DISPLAY.map { |i|
    "\"#{i}\",\"#{@env[i]}\"\r\n"
  }.join
end

