require 'rubygems'
require 'bundler'

Bundler.require

class Hello < Sinatra::Base

  get '/' do
    erb :index
  end

  get '/whoa' do
    erb :whoa
  end

  run! if app_file == $0
end
