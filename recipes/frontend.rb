#
# Cookbook Name:: zabbix3
# Recipe:: frontend
#
# Copyright (c) 2016 Robert Ressl, GPL v3.

%w(nginx php5-fpm zabbix-frontend-php).each do |pkg|
  package pkg do
    action :install
    options '--no-install-recommends'
  end
end

directory '/etc/nginx/global' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory '/var/log/zabbix' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

file '/etc/nginx/conf.d/default.conf' do
  action :delete
end

template '/etc/default/nginx' do
  source 'frontend/nginx.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    ulimit: node['zabbix3']['frontend']['nginx']['ulimit'],
    daemon_args: node['zabbix3']['frontend']['nginx']['daemon_args']
  )
end

template '/etc/nginx/nginx.conf' do
  source 'frontend/nginx.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    worker_connections: node['zabbix3']['frontend']['nginx']['worker_connections']
  )
end

template '/etc/nginx/conf.d/zabbix.conf' do
  source 'frontend/zabbix.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    server_name: node['zabbix3']['frontend']['nginx']['server_name']
  )
end

template '/etc/nginx/global/fastcgi-php.conf' do
  source 'frontend/fastcgi-php.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template '/etc/nginx/fastcgi.conf' do
  source 'frontend/fastcgi.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template '/etc/nginx/global/php.conf' do
  source 'frontend/php.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template '/etc/php5/fpm/pool.d/www.conf' do
  source 'frontend/www.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    max_children: node['zabbix3']['frontend']['php']['max_children'],
    start_servers: node['zabbix3']['frontend']['php']['start_servers'],
    min_spare_servers: node['zabbix3']['frontend']['php']['min_spare_servers'],
    max_spare_servers: node['zabbix3']['frontend']['php']['max_spare_servers'],
    max_requests: node['zabbix3']['frontend']['php']['max_requests'],
    process_idle_timeout: node['zabbix3']['frontend']['php']['process_idle_timeout'],
    max_execution_time: node['zabbix3']['frontend']['php']['php_admin_value']['max_execution_time'],
    memory_limit: node['zabbix3']['frontend']['php']['php_admin_value']['memory_limit'],
    post_max_size: node['zabbix3']['frontend']['php']['php_admin_value']['post_max_size'],
    upload_max_filesize: node['zabbix3']['frontend']['php']['php_admin_value']['upload_max_filesize'],
    max_input_time: node['zabbix3']['frontend']['php']['php_admin_value']['max_input_time'],
    always_populate_raw_post_data: node['zabbix3']['frontend']['php']['php_admin_value']['always_populate_raw_post_data'],
    timezone: node['zabbix3']['frontend']['php']['php_admin_value']['date_timezone']
  )
end

directory '/etc/zabbix/web' do
  owner 'www-data'
  group 'www-data'
  mode '0700'
  action :create
end

template '/etc/zabbix/web/zabbix.conf.php' do
  source 'frontend/zabbix.conf.php.erb'
  owner 'www-data'
  group 'www-data'
  mode '0400'
  variables(
    host: node['zabbix3']['server']['db']['host'],
    port: node['zabbix3']['server']['db']['port'],
    name: node['zabbix3']['server']['db']['name'],
    user: node['zabbix3']['server']['db']['user'],
    password: node['zabbix3']['server']['db']['password'],
    zabbix_server: node['zabbix3']['server']['server'],
    zabbix_port: node['zabbix3']['server']['port'],
    zabbix_name: node['zabbix3']['server']['name']
  )
end

service 'nginx' do
  supports reload: 'true', restart: 'true', start: 'true', stop: 'true'
  action [:enable, :start]
  subscribes :restart, 'template[/etc/default/nginx]', :delayed
  subscribes :reload, 'template[/etc/nginx/nginx.conf]', :delayed
  subscribes :reload, 'template[/etc/nginx/conf.d/zabbix.conf]', :delayed
  subscribes :reload, 'template[/etc/nginx/global/fastcgi-php.conf]', :delayed
  subscribes :reload, 'template[/etc/nginx/fastcgi.conf]', :delayed
  subscribes :reload, 'template[/etc/nginx/global/php.conf]', :delayed
end

service 'php5-fpm' do
  supports reload: 'true', restart: 'true', start: 'true', stop: 'true'
  action [:enable, :start]
  subscribes :restart, 'template[/etc/php5/fpm/pool.d/www.conf]', :delayed
end
