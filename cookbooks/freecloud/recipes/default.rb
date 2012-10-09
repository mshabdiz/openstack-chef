# Turns out that AppArmor isn't good for your health...

execute "sudo dd if=/dev/zero of=/opt/openstack/swap bs=1G count=50;sudo mkswap /opt/openstack/swap;sudo swapon /opt/openstack/swap" do
    not_if "swapon -s | grep /opt/openstack/swap"
end
execute "sudo ifconfig eth1 up"

execute "sudo ufw allow from 10.0.100.0/24 to any port 22"
execute "sudo ufw allow from 10.0.100.0/24 to any port 5666"
execute "sudo ufw enable"

execute "apt-get update" do
    command "sudo apt-get update"
    action :run
end

directory "/opt/stack/.ssh" do
    recursive true
end

user "stack" do
   home "/opt/stack"
   shell "/bin/bash"
end

template "/opt/stack/.ssh/authorized_keys" do
    source "ssh_key.erb"
    owner "stack"
    group "stack"
    mode 0600
end

package "python-setuptools"

package "git"

