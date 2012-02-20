#
# Cookbook Name:: dash
# Recipe:: mysql
#
# Copyright 2010, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

execute "mysql-install-dash-privileges" do
  command "/usr/bin/mysql -u root -p#{node[:mysql][:server_root_password]} < /etc/mysql/dash-grants.sql"
  action :nothing
end

Chef::Log.info("Mysql recipe included")

include_recipe "mysql::server"
require 'rubygems'
Gem.clear_paths
require 'mysql'

template "/etc/mysql/dash-grants.sql" do
  path "/etc/mysql/dash-grants.sql"
  source "grants.sql.erb"
  owner "root"
  group "root"
  mode "0600"
  variables(
    :user     => node[:dash][:db_user],
    :password => node[:dash][:db_password],
    :database => node[:dash][:db_name]
  )
  notifies :run, resources(:execute => "mysql-install-dash-privileges"), :immediately
end

execute "create #{node[:dash][:db_name]} database" do
  command "/usr/bin/mysqladmin -u root -p#{node[:mysql][:server_root_password]} create #{node[:dash][:db_name]}"
  not_if do
    m = Mysql.new("localhost", "root", node[:mysql][:server_root_password])
    m.list_dbs.include?(node[:dash][:db_name])
  end
end

# save data so it can be found by search
unless Chef::Config[:solo]
  Chef::Log.info("Saving node data")
  node.save
end
