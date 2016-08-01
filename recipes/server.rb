#
# Cookbook Name:: zabbix3
# Recipe:: server
#
# Copyright (c) 2016 Robert Ressl, GPL v3.

host = node['zabbix3']['server']['db']['host']
port = node['zabbix3']['server']['db']['port']
name = node['zabbix3']['server']['db']['name']
user = node['zabbix3']['server']['db']['user']
password = node['zabbix3']['server']['db']['password']
db_file = "/var/lib/mysql/#{node['zabbix3']['server']['db']['name']}/maintenances.frm"

%w(mysql-client zabbix-server-mysql).each do |pkg|
  package pkg do
    action :install
    options '--no-install-recommends'
  end
end

template '/etc/zabbix/zabbix_server.conf' do
  source 'server/zabbix_server.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    alert_scripts: node['zabbix3']['server']['path']['alert_scripts'],
    external_scripts: node['zabbix3']['server']['path']['external_scripts'],
    host: node['zabbix3']['server']['db']['host'],
    port: node['zabbix3']['server']['db']['port'],
    name: node['zabbix3']['server']['db']['name'],
    user: node['zabbix3']['server']['db']['user'],
    password: node['zabbix3']['server']['db']['password'],
    fping6: node['zabbix3']['server']['location']['fping6'],
    fping: node['zabbix3']['server']['location']['fping'],
    log_file: node['zabbix3']['server']['log']['file'],
    log_file_size: node['zabbix3']['server']['log']['file_size'],
    slowqueries: node['zabbix3']['server']['log']['slowqueries'],
    pidfile: node['zabbix3']['server']['pidfile'],
    timeout: node['zabbix3']['server']['timeout'],
    start: node['zabbix3']['server']['poller']['start'],
    ipmi: node['zabbix3']['server']['poller']['ipmi'],
    unreachable: node['zabbix3']['server']['poller']['unreachable'],
    trappers: node['zabbix3']['server']['poller']['trappers'],
    pingers: node['zabbix3']['server']['poller']['pingers'],
    discoverers: node['zabbix3']['server']['poller']['discoverers'],
    http: node['zabbix3']['server']['poller']['http'],
    timers: node['zabbix3']['server']['poller']['timers'],
    escalators: node['zabbix3']['server']['poller']['escalators']
  )
end

execute 'zabbix_db_initial' do
  command "zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz |  mysql -u #{user} -h #{host} -P #{port} --password=#{password} #{name}"
  not_if { File.exist?(db_file) }
end

service 'zabbix-server' do
  supports restart: 'true', start: 'true', stop: 'true'
  action [:enable, :start]
  subscribes :restart, 'template[/etc/zabbix/zabbix_server.conf]', :delayed
end
