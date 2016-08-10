#
# Cookbook Name:: zabbix3
# Recipe:: repository
#
# Copyright (c) 2016 Robert Ressl, GPL v3.

case node[:platform]
when 'ubuntu'
  apt_repository 'zabbix' do
    uri 'http://repo.zabbix.com/zabbix/3.0/ubuntu'
    components ['main']
    key '0x082ab56ba14fe591'
    keyserver 'keyserver.ubuntu.com'
  end
when 'debian'
  apt_repository 'zabbix' do
    uri 'http://repo.zabbix.com/zabbix/3.0/debian'
    components ['main']
    key 'http://repo.zabbix.com/zabbix-official-repo.key'
  end
when 'redhat', 'centos'
  yum_repository 'zabbix' do
    description 'Zabbix repo'
    baseurl 'http://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/'
    gpgkey 'http://repo.zabbix.com/RPM-GPG-KEY-ZABBIX'
    action :create
  end
end

case node[:platform]
when 'ubuntu'
  apt_repository 'nginx' do
    uri 'http://nginx.org/packages/ubuntu/'
    components ['nginx']
    key 'http://nginx.org/keys/nginx_signing.key'
  end
when 'debian'
  apt_repository 'nginx' do
    uri 'http://nginx.org/packages/debian/'
    components ['nginx']
    key 'http://nginx.org/keys/nginx_signing.key'
  end
when 'redhat', 'centos'
  yum_repository 'nginx' do
    description 'Nginx repo'
    baseurl 'http://nginx.org/packages/mainline/centos/7/$basearch/'
    gpgkey 'http://nginx.org/keys/nginx_signing.key'
    action :create
  end
end
