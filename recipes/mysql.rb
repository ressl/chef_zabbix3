#
# Cookbook Name:: zabbix3
# Recipe:: mysql
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

name = node['zabbix3']['server']['db']['name']
user = node['zabbix3']['server']['db']['user']
password = node['zabbix3']['server']['db']['password']
db_file = "/var/lib/mysql/#{node['zabbix3']['server']['db']['name']}/db.opt"

# mysql_service 'zabbix' do
#   port '3306'
#   version '5.5.50-0ubuntu0.14.04.1'
#   initial_root_password 'setup123'
#   action [:create, :start]
# end

# Workaround; waiting for fix in mysql and database cookbook
package 'mysql-server' do
  action :install
end

# Workaround; waiting for fix in mysql and database cookbook
package 'mysql-client' do
  action :install
end

# Workaround; waiting for fix in mysql and database cookbook
bash 'mysql' do
  code <<-EOH
    mysql -uroot -r -B -N -e "CREATE DATABASE IF NOT EXISTS #{name};"
    mysql -uroot -r -B -N -e "CREATE USER '#{user}'@'%' IDENTIFIED BY '#{password}';"
    mysql -uroot -r -B -n -e "GRANT ALL PRIVILEGES ON #{name}.* TO '#{user}'@'%';"
    mysql -uroot -r -B -n -e "FLUSH PRIVILEGES;"
  EOH
  not_if { File.exist?(db_file) }
end

template '/etc/mysql/my.cnf' do
  source 'mysql/my.cnf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    ip: node['ipaddress']
  )
end

service 'mysql' do
  supports reload: 'true', restart: 'true', start: 'true', stop: 'true'
  action [:enable, :start]
  subscribes :restart, 'template[/etc/mysql/my.cnf]', :delayed
end

# mysql2_chef_gem 'default' do
#   action :install
# end

# mysql_chef_gem 'default' do
#   action :install
# end

# mysql_connection_info = {
#   host: '127.0.0.1',
#   username: 'root',
# }

# mysql_database 'zabbix' do
#   connection    mysql_connection_info
#   action :create
# end

# mysql_database_user 'zabbix' do
#   connection mysql_connection_info
#   password   'setup123'
#   action     :create
# end

# mysql_database_user 'zabbix' do
#   connection    mysql_connection_info
#   password      'setup123'
#   database_name 'zabbix'
#   host          '%'
#   privileges    [:all]
#   action        [:create, :grant]
# end
