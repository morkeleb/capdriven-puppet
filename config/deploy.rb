set :application, "capdriven-puppet"
set :repository,  "git@github.com:morkeleb/capdriven-puppet.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :gateway, 'ec2-user@54.246.155.9'

role :web, "10.0.1.162"                          # Your HTTP server, Apache/etc
role :web, "10.0.1.168"                          # Your HTTP server, Apache/etc
role :db, "10.0.0.171"                          # Your HTTP server, Apache/etc
#role :app, "your app-server here"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

   default_run_options[:pty] = true # need to tell ssh to do this so we can use try_sudo

ssh_options[:keys] = ["#{ENV['HOME']}/.ec2/capdriven-puppet.pem"] #unless 'development' == rails_env

#bootstrap from https://gist.github.com/3072375
#modified to install puppet on the server

desc 'Boostraps a server by installing puppet and applying puppet manifest'
namespace :bootstrap do
  task :default do
    # Specific RVM string for managing Puppet; may or may not match the RVM string for the application
    set :user, "ec2-user"

    # Set the default_shell to "bash" so that we don't use the RVM shell which isn't installed yet...
    set :default_shell, "bash"

    try_sudo("yum -y install puppet") #install puppet, -y assumes answer yes on all questions.

    #inspiration here to run specific .pp file for the specific role: http://bentis.calepin.co/pulling-puppets-strings-with-capistrano.html

    # We tar up the puppet directory from the current directory -- the puppet directory within the source code repository
    system("tar cczf 'puppet.tgz' config/puppet/")
    upload("puppet.tgz","/home/#{user}",:via => :scp)
    system("rm puppet.tgz") # clean up junk!

    # Untar the puppet directory, and place at /etc/puppet -- the default location for manifests/modules
    run("tar xzf puppet.tgz")
    run("rm puppet.tgz")

  end 

  after "bootstrap", :roles=>[:web] do 
  	# here we place code specific for configuring the web role using puppet
  	try_sudo("puppet apply config/puppet/web.pp")
  end
end


# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end