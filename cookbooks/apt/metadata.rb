maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Configures apt and apt services"
version           "0.9.3"
recipe            "apt", "Runs apt-get update during compile phase and sets up preseed directories"
recipe            "apt::cacher", "Set up an APT cache"
recipe            "apt::proxy", "Set up an APT proxy"
depends           "nginx"

%w{ ubuntu debian }.each do |os|
  supports os
end
