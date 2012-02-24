#
# Cookbook Name:: memcache
# Recipe:: default
#
# Copyright 2009, Example Com
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

group "dash" do
end

user "dash" do
  gid "dash"
end

package "git" do
    action :install
end

package "python-pip" do
    action :install
end

package "python-django" do
    action :install
end

package "python-mailer" do
    action :install
end

#package "openstack-dashboard" do
#    action :install
#    options "--force-yes"
#end

git "/var/lib/dash" do
    repository "https://github.com/ntt-pf-lab/horizon.git"
    revision "freecloud"
    action :sync
end

git "/var/lib/openstackx" do
    repository "https://github.com/cloudbuilders/openstackx.git"
    revision "diablo"
    action :sync
end

git "/var/lib/openstack" do
    repository "https://github.com/jacobian/openstack.compute.git"
    revision "master"
    action :sync
end

remote_directory "/var/www/html" do
    source "html"
    overwrite true
end

directory "/var/lib/dash/.blackhole" do
end

directory "/home/dash" do
    owner "dash"
    group "dash"
end

execute "sudo pip install -r pip-requires" do
    cwd "/var/lib/dash/openstack-dashboard/tools"
end

#execute "sudo easy_install --upgrade django"

execute "sudo python setup.py develop" do
    cwd "/var/lib/dash/django-openstack"
end

execute "sudo python setup.py develop" do
    cwd "/var/lib/dash/openstack-dashboard"
end

execute "sudo python setup.py develop" do
    cwd "/var/lib/openstackx"
end

execute "sudo python setup.py develop" do
    cwd "/var/lib/openstack"
end



package "apache2" do
  action :install
end

package "libapache2-mod-wsgi" do
  action :install
end

service "apache2" do
  supports :status => true, :reload => true, :restart => true
  action :enable
end

execute "a2enmod rewrite" do
        command "a2enmod rewrite"
        action :run
        notifies :restart, resources(:service => "apache2"), :delayed
end

execute "a2enmod proxy" do
        command "a2enmod proxy"
        action :run
        notifies :restart, resources(:service => "apache2"), :delayed
end

execute "a2enmod proxy_http" do
        command "a2enmod proxy_http"
        action :run
        notifies :restart, resources(:service => "apache2"), :delayed
end


execute "a2enmod ssl" do
        command "a2enmod ssl"
        action :run
        notifies :restart, resources(:service => "apache2"), :delayed
end

execute "a2enmod substitute" do
        command "a2enmod substitute"
        action :run
        notifies :restart, resources(:service => "apache2"), :delayed
end


execute "a2enmod wsgi" do
        command "a2enmod wsgi"
        action :run
        notifies :restart, resources(:service => "apache2"), :immediately
end

template "/etc/apache2/sites-available/dash" do
       source "dash.erb"
end

execute "sudo a2ensite dash" do
        command "a2ensite dash"
        action :run
        notifies :reload, resources(:service => "apache2"), :immediately
end

template "/etc/apache2/sites-available/default-ssl" do
       source "default-ssl.erb"
end

execute "sudo a2ensite default-ssl" do
        command "a2ensite default-ssl"
        action :run
        notifies :reload, resources(:service => "apache2"), :immediately
end


execute "sudo a2dissite default" do
  command "a2dissite default"
  action :run
  notifies :reload, resources(:service => "apache2"), :immediately
end

env_filter = ''
if node[:app_environment]
  env_filter = " AND app_environment:#{node[:app_environment]}"
end

if node[:dash][:mysql]
  Chef::Log.info("Using mysql")
  package "python-mysqldb"
  mysqls = nil
  unless Chef::Config[:solo]
    mysqls = search(:node, "recipes:nova\\:\\:mysql#{env_filter}")
  end
  if mysqls and mysqls[0]
    mysql = mysqls[0]
    Chef::Log.info("Mysql server found at #{mysql[:mysql][:bind_address]}")
  else
    mysql =
    Chef::Log.info("Using local mysql at  #{mysql[:mysql][:bind_address]}")
  end
  node[:dash][:db_host] = mysql[:mysql][:bind_address]
end

remote_directory "/var/lib/dash/quantum" do
    source "quantum"
end

template "/var/lib/dash/openstack-dashboard/local/local_settings.py" do
  source "local_settings.py.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :user =>   node[:dash][:db_user],
    :passwd =>   node[:dash][:db_password],
    :api_host =>   node[:dash][:api_host],
    :db_host =>   node[:dash][:db_host],
    :db_name =>   node[:dash][:db_name],
    :service_port =>   node[:dash][:keystone_service_port],
    :admin_token =>   node[:dash][:keystone_admin_token],
    :nova_username => node[:dash][:nova_username],
    :nova_password => node[:dash][:nova_password],
    :nova_tenant => node[:dash][:nova_tenant],
    :facebook_app_id => node[:dash][:facebook_app_id],
    :facebook_api_secret => node[:dash][:facebook_api_secret]
  )
end

execute "PYTHONPATH=/var/lib/dash/openstack-dashboard python dashboard/manage.py syncdb" do
  cwd "/var/lib/dash/openstack-dashboard"
  environment ({'PYTHONPATH' => '/var/lib/dash/openstack-dashboard'})
  command "python dashboard/manage.py syncdb"
  action :run
  notifies :restart, resources(:service => "apache2"), :immediately
end

execute "sudo ufw allow 80"
execute "sudo ufw allow 443"
execute "sudo ufw allow 9774"
execute "sudo ufw allow 9773"
execute "sudo ufw allow 5443"


