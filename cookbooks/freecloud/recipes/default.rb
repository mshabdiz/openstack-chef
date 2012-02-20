execute "sudo invoke-rc.d apparmor stop"
execute "sudo update-rc.d -f apparmor remove"

package "apparmor" do
    action :remove
end

cookbook_file "/etc/apt/sources.list" do
    source "etc/apt/sources.list"
    owner "root"
    group "root"
    mode 0644
end

execute "rm -rf /var/log;" do
    only_if "test -d /var/log"
end

execute "ln -s /opt/openstack/log/ /var/log;"


execute "sudo add-apt-repository ppa:openstack-release/2011.3"
execute "sudo ifconfig eth1 up"

execute "sudo ufw allow from 10.0.100.0/24 to any port 22"
execute "sudo ufw allow from 10.0.100.0/24 to any port 5666"
execute "sudo ufw enable"

execute "apt-get update" do
    command "sudo apt-get update"
    action :run
end

execute "sudo ntpdate-debian"

package "git"

