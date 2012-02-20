name "keystone-mysql-server"
description "MySQL server for keystone"

run_list(
  "recipe[mysql::server]",
  "recipe[keystone::mysql]"
)

default_attributes(
  "keystone" => {
    "mysql" => true
  }
)
