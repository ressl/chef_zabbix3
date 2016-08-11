#
# Cookbook Name:: zabbix3
# Recipe:: agent
#
# Copyright (c) 2016 Robert Ressl, GPL v3.

package 'zabbix-agent' do
  action :install
end

template '/etc/zabbix/zabbix_agentd.conf' do
  source 'agent/zabbix_agentd.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    hostname: node['zabbix3']['agent']['hostname'],
    include: node['zabbix3']['agent']['include'],
    log_file: node['zabbix3']['agent']['log']['file'],
    log_file_size: node['zabbix3']['agent']['log']['file_size'],
    pidfile: node['zabbix3']['agent']['pidfile'],
    server: node['zabbix3']['agent']['server'],
    server_active: node['zabbix3']['agent']['server_active'],
    psk_connect: node['zabbix3']['agent']['tls']['psk']['connect'],
    pks_accept: node['zabbix3']['agent']['tls']['psk']['accept'],
    psk_file: node['zabbix3']['agent']['tls']['psk']['keyfile'],
    psk_identity: node['zabbix3']['agent']['tls']['psk']['identity']
  )
end

template '/etc/zabbix/zabbix_agentd.psk' do
  source 'agent/zabbix_agentd.psk.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    psk: node['zabbix3']['agent']['tls']['psk']['psk_key']
  )
end

service 'zabbix-agent' do
  supports restart: 'true', start: 'true', stop: 'true'
  action [:enable, :start]
  subscribes :restart, 'template[/etc/zabbix/zabbix_agentd.conf]', :delayed
  subscribes :restart, 'template[/etc/zabbix/zabbix_agentd.psk]', :delayed
end
