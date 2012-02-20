#
# Cookbook Name:: keystone
# Attributes:: database
#
#::Chef::Node.send(:include, Opscode::OpenSSL::Password)

#set_unless[:keystone][:db][:password] = secure_password
default[:keystone][:db][:user] = "keystone"
default[:keystone][:db][:database] = "keystone"
default[:keystone][:db][:sql_idle_timeout] = "60"
