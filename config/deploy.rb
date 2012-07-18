set :application, "ishlist"
set :scm, :git
set :repository,  "git@github.com:tonysano/IshList.git"
set :scm_username, "vinaymehta" 
set :scm_password, "changeit"
set :scm_passphrase, "changeit"
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :runner, 'root'
set :use_sudo, false
set :user,"root"
set :password, "2Ots2VfP4Ishlist"
default_run_options[:pty] = true 
require 'capistrano/ext/multistage'
set :stages, ["staging", "production"]
set :default_stage, "staging"
#set :deploy_to, "/var/www/ishlist_staging"
role :web, "108.166.83.106"                          # Your HTTP server, Apache/etc
role :app, "108.166.83.106"                          # This may be the same as your `Web` server
role :db,  "108.166.83.106", :primary => true # This is where Rails migrations will run
role :db,  "108.166.83.106"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
 namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app do
    run "chmod 777 #{current_path} -R"
    run "touch #{current_path}/tmp/restart.txt"    
  end
end


namespace :deploy do
 task :start, :roles => :app do
   run "chmod 777 #{current_path} -R"
   run "touch #{current_release}/tmp/restart.txt"
 end
end
