require './config/settings.rb'

require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'

set :shared_paths, ['log']

task :environment do
  invoke :'rbenv:load'
end

task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[touch "#{deploy_to}/shared/rack.pid"]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'

    to :launch do
      queue "if [ -f rack.pid ]; then kill `cat rack.pid`; rm rack.pid; fi"
      queue "rackup -D -p 4567 -s thin -P rack.pid config.ru;"
    end
  end
end
