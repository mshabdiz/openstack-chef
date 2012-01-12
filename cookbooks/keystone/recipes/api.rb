#
# Cookbook Name:: keystone
# Recipe:: api
#
#

sql_connection = nil
if node[:keystone][:mysql]
  Chef::Log.info("Using mysql")
  package "python-mysqldb"
  mysqls = nil

  unless Chef::Config[:solo]
    mysqls = search(:node, "recipes:keystone\\:\\:mysql")
  end
  if mysqls and mysqls[0]
    mysql = mysqls[0]
    Chef::Log.info("Mysql server found at #{mysql[:mysql][:bind_address]}")
  else
    mysql = node
    Chef::Log.info("Using local mysql at  #{mysql[:mysql][:bind_address]}")
  end
  sql_connection = "mysql://#{mysql[:keystone][:db][:user]}:#{mysql[:keystone][:db][:password]}@#{mysql[:mysql][:bind_address]}/#{mysql[:keystone][:db][:database]}"
else
  # default to sqlite
  sql_connection = "sqlite:////var/lib/keystone/keystone.sqlite"
end

node[:keystone][:sql_connection] = sql_connection

package "keystone" do
  options "--force-yes"
  action :install
end

directory File.dirname(node[:keystone][:config_file]) do
  owner "keystone"
  group "root"
  mode "0755"
  action :create
end

directory File.dirname(node[:keystone][:db_file]) do
  owner "keystone"
  group "root"
  mode "0755"
  action :create
end

directory File.dirname(node[:keystone][:log_config]) do
  owner "keystone"
  group "root"
  mode "0755"
  action :create
end

template node[:keystone][:config_file] do
  source "keystone.conf.erb"
  owner "keystone"
  group "root"
  mode 0644
end

template node[:keystone][:log_config] do
  source "logging.cnf.erb"
  owner "keystone"
  group "root"
  mode 0644
end

keystone_svc_name="keystone"
service keystone_svc_name do
  if (platform?("ubuntu") && node.platform_version.to_f >= 10.04)
    restart_command "restart #{keystone_svc_name}"
    stop_command "stop #{keystone_svc_name}"
    start_command "start #{keystone_svc_name}"
    status_command "status #{keystone_svc_name} | cut -d' ' -f2 | cut -d'/' -f1 | grep start"
  end
  supports :status => true, :restart => true
  action :start
  subscribes :restart, resources(:template => node[:keystone][:config_file])
end
