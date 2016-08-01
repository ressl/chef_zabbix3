name 'zabbix3'
maintainer 'Robert Ressl'
maintainer_email 'r.ressl@safematix.com'
license 'GPL v3'
description 'Installs/Configures zabbix3'
long_description 'Installs/Configures zabbix3'
source_url       'https://github.com/safematix/chef_zabbix3'  if respond_to?(:source_url)
issues_url       'https://github.com/safematix/chef_zabbix3/issues' if respond_to?(:issues_url)
version '0.1.3'

%w(debian ubuntu redhat centos fedora).each do |os|
  supports os
end

chef_version '>= 12.0' if respond_to?(:chef_version)\

depends 'apt', '~> 4.0.1'
depends 'yum', '~> 3.11.0'
# depends 'mysql', '~> 8.0'
# depends 'database', '~> 5.1.2'
# depends 'mysql2_chef_gem', '~> 1.0'
# depends 'mysql_chef_gem', '~> 3.0.1'
