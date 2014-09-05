require './config/settings.rb'

require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'

set :shared_paths, ['log', 'tmp']

task :environment do
  invoke :'rbenv:load'
end

task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp"]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'

    to :launch do
      invoke :restart
    end
  end
end

desc "Restarts the current release."
task :restart => :environment do
  in_directory "#{deploy_to}/current" do
    queue "if [ -f tmp/rack.pid ]; then kill -9 `cat tmp/rack.pid`; rm tmp/rack.pid; fi"
    queue "rackup -D -p 4567 -s thin -P tmp/rack.pid"
  end
end
