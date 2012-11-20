set :application, "capdriven-puppet"
set :repository,  "git@github.com:morkeleb/capdriven-puppet.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "ec2-176-34-161-163.eu-west-1.compute.amazonaws.com"                          # Your HTTP server, Apache/etc
#role :app, "your app-server here"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

   default_run_options[:pty] = true # need to tell ssh to do this so we can use try_sudo

ssh_options[:keys] = ["#{ENV['HOME']}/.ec2/capdriven-puppet.pem"] #unless 'development' == rails_env

#bootstrap from https://gist.github.com/3072375
#modified to install puppet on the server
namespace :bootstrap do
  task :default do
    # Specific RVM string for managing Puppet; may or may not match the RVM string for the application
    set :user, "ec2-user"

    # Set the default_shell to "bash" so that we don't use the RVM shell which isn't installed yet...
    set :default_shell, "bash"

    try_sudo("yum -y install puppet") #install puppet, -y assumes answer yes on all questions.

    # We tar up the puppet directory from the current directory -- the puppet directory within the source code repository
    system("tar cczf 'puppet.tgz' puppet/")
    upload("puppet.tgz","/home/#{user}",:via => :scp)

    # Untar the puppet directory, and place at /etc/puppet -- the default location for manifests/modules
    run("tar xzf puppet.tgz")
    try_sudo("rm -rf /etc/puppet")
    try_sudo("mv /home/#{user}/puppet/ /etc/puppet")

    # Bootstrap RVM/Puppet!
    try_sudo("bash /etc/puppet/bootstrap.sh")
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