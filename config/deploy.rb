require 'mina/bundler'
require 'mina/git'
require 'mina/rbenv'

require './config/settings.rb'

set :domain, Configuration::SERVER['host']
set :deploy_to, Configuration::SERVER['deploy_to']

set :repository, Configuration::GIT['repository']
set :branch, Configuration::GIT['branch']

set :user, Configuration::SSH['user']
set :forward_agent, Configuration::SSH['forward_agent']
set :identity_file, Configuration::SSH['identity_file']

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

desc "Restart the server."
task :restart => :environment do
  in_directory "#{deploy_to}/#{current_path}" do
    queue "bundle exec thin -R config.ru -p 4567 -d restart"
  end
end

desc "Start the server."
task :start => :environment do
  in_directory "#{deploy_to}/#{current_path}" do
    queue "bundle exec thin -R config.ru -p 4567 -d start"
  end
end

desc "Stop the server."
task :stop => :environment do
  in_directory "#{deploy_to}/#{current_path}" do
    queue "bundle exec thin -R config.ru -p 4567 -d stop"
  end
end

desc "Report server process id"
task :info => :environment do
  in_directory "#{deploy_to}/#{shared_path}" do
    queue "print 'Server running with pid:' `cat tmp/pids/thin.pid`"
  end
end
