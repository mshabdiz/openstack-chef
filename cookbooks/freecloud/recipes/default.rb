# Turns out that AppArmor isn't good for your health...
package "apparmor" do
    action :remove
end

cookbook_file "/etc/apt/sources.list" do
    source "etc/apt/sources.list"
    owner "root"
    group "root"
    mode 0644
end

execute "sudo dd if=/dev/zero of=/opt/openstack/swap bs=1G count=50;sudo mkswap /opt/openstack/swap;sudo swapon /opt/openstack/swap" do
    not_if "swapon -s | grep /opt/openstack/swap"
end

execute "sudo add-apt-repository ppa:openstack-release/2011.3"
execute "sudo ifconfig eth1 up"

execute "sudo ufw allow from 10.0.100.0/24 to any port 22"
execute "sudo ufw allow from 10.0.100.0/24 to any port 5666"
execute "sudo ufw enable"

execute "apt-get update" do
    command "sudo apt-get update"
    action :run
end

package "python-setuptools"

package "git"

