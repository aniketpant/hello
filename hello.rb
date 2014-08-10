require 'rubygems'
require 'sinatra/base'

class Hello < Sinatra::Base

  get '/' do
    "Is it me you're looking for?"
  end

  run! if app_file == $0
end
