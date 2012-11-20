Start with an empty repo

Capify it

add git configuration

add server to bootstrap, after creating it on ec2. I'm using Amazon Linux.
Starting with one server.

add shh config for connecting to ec2

add bootstrap task and make sure yum installs puppet when bootstraping.
yum install is idempotent so we can rerun the bootstrap.
I think this is all we need and we can do the type specific bootstrapping.

Have to bootstrap task upload the puppet files, modules etc.

run a task specific per role to run puppet, its the only way to get a specific role unfortunatly.

