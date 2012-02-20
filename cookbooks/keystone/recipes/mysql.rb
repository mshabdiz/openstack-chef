#
# Cookbook Name:: keystone
# Recipe:: mysql
#

execute "mysql-install-keystone-privileges" do
  command "/usr/bin/mysql -u root -p#{node[:mysql][:server_root_password]} < /etc/mysql/keystone-grants.sql"
  action :nothing
end

node[:mysql][:bind_address] = node[:keystone][:my_ip]

Chef::Log.info("Mysql recipe included")

include_recipe "mysql::server"
require 'rubygems'
Gem.clear_paths
require 'mysql'

template "/etc/mysql/keystone-grants.sql" do
  path "/etc/mysql/keystone-grants.sql"
  source "grants.sql.erb"
  owner "root"
  group "root"
  mode "0600"
  variables(
    :user     => node[:keystone][:db][:user],
    :password => node[:keystone][:db][:password],
    :database => node[:keystone][:db][:database]
  )
  notifies :run, resources(:execute => "mysql-install-keystone-privileges"), :immediately
end

execute "create #{node[:keystone][:db][:database]} database" do
  command "/usr/bin/mysqladmin -u root -p#{node[:mysql][:server_root_password]} create #{node[:keystone][:db][:database]}"
  not_if do
    m = Mysql.new("localhost", "root", node[:mysql][:server_root_password])
    m.list_dbs.include?(node[:keystone][:db][:database])
  end
end

# save data so it can be found by search
unless Chef::Config[:solo]
  Chef::Log.info("Saving node data")
  node.save
end
