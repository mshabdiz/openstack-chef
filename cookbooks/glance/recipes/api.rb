#
# Cookbook Name:: glance
# Recipe:: api
#
#

include_recipe "#{@cookbook_name}::common"

cache = node[:glance][:cache] == "True" ? "cache" : ""
cachemanage = node[:glance][:cache_management] == "True" ? "cachemanage" : ""

template node[:glance][:api_config_file] do
  source "glance-api.conf.erb"
  owner "glance"
  group "root"
  mode 0644
  variables(
    :cache => cache,
    :cachemanage => cachemanage
  )
end

template node[:glance][:cache_config_file] do
  source "glance-cache.conf.erb"
  owner "glance"
  group "root"
  mode 0644
end

template node[:glance][:scrubber_config_file] do
  source "glance-scrubber.conf.erb"
  owner "glance"
  group "root"
  mode 0644
end

glance_service "api"

file "/var/log/glance/api.log" do
  owner "glance"
  group "root"
  mode "0644"
  action :create
  notifies :restart, resources(:service => "glance-api"), :immediately
end

["", "incomplete", "invalid", "queue"].each do |cache_dir|

  directory "#{node[:glance][:image_cache_dir]}/#{cache_dir}" do
    owner "glance"
    group "root"
    mode "0755"
    action :create
  end

end

execute "sudo ufw allow from 10.0.100.0/24 to any port 9292"

