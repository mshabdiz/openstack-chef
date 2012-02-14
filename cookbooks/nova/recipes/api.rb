#
# Cookbook Name:: nova
# Recipe:: api
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

include_recipe "nova::common"

git "/var/lib/openstackx" do
    repository "https://github.com/cloudbuilders/openstackx.git"
    reference "diablo"
    action :sync
end

#FIXME: This should come out if/when we require python-keystone in api package
if node[:nova][:auth_type] and node[:nova][:auth_type] == "keystone" then
  package "python-keystone"
end

nova_package("api")

template "/etc/nova/api-paste.ini" do
  source "api-paste.ini.erb"
  owner "nova"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "nova-api")

end

execute "sudo ufw allow 8774"

