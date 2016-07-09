#
# Cookbook Name:: fluent-agent-lite
# Recipe:: rpmbuild
#
# Copyright 2014, bageljp
#
# All rights reserved - Do Not Redistribute
#

%w(
  perl-YAML-Tiny
  perl-Module-Install
  perl-Time-HiRes
).each do |pkg|
  package pkg do
    action :install
    options "--enablerepo=epel"
  end
end

directory "#{node['fluent-agent-lite']['rpmbuild']['root_dir']}" do
  owner "#{node['fluent-agent-lite']['rpmbuild']['user']}"
  group "#{node['fluent-agent-lite']['rpmbuild']['group']}"
  mode 00755
  recursive true
end

%w(
  BUILD
  SOURCES
  SPECS
  SRPMS
  RPMS
).each do |d|
  directory "#{node['fluent-agent-lite']['rpmbuild']['root_dir']}/#{d}" do
    owner "#{node['fluent-agent-lite']['rpmbuild']['user']}"
    group "#{node['fluent-agent-lite']['rpmbuild']['group']}"
    mode 00755
    recursive true
  end
end

remote_file "#{node['fluent-agent-lite']['rpmbuild']['root_dir']}/SOURCES/fluent-agent-lite.#{node['fluent-agent-lite']['version']}.tar.gz" do
  owner "#{node['fluent-agent-lite']['rpmbuild']['user']}"
  group "#{node['fluent-agent-lite']['rpmbuild']['group']}"
  mode 00644
  source "#{node['fluent-agent-lite']['rpmbuild']['url']}"
end

bash "rpmbuild fluent-agent-lite" do
  user "#{node['fluent-agent-lite']['rpmbuild']['user']}"
  group "#{node['fluent-agent-lite']['rpmbuild']['group']}"
  cwd "#{node['fluent-agent-lite']['rpmbuild']['root_dir']}/SOURCES"
  environment "HOME" => "#{node['fluent-agent-lite']['rpmbuild']['home_dir']}"
  code <<-EOC
    rm -rf fluent-agent-lite-#{node['fluent-agent-lite']['version']}
    tar zxf fluent-agent-lite.#{node['fluent-agent-lite']['version']}.tar.gz
    cp -p fluent-agent-lite-#{node['fluent-agent-lite']['version']}/SPECS/fluent-agent-lite.spec ../SPECS
    cd ../SPECS
    rpmbuild -ba --define "%_topdir #{node['fluent-agent-lite']['rpmbuild']['root_dir']}" --define "%__arch_install_post /usr/lib/rpm/check-rpaths /usr/lib/rpm/check-buildroot" fluent-agent-lite.spec
  EOC
  creates "#{node['fluent-agent-lite']['rpmbuild']['root_dir']}/RPMS/x86_64/#{node['fluent-agent-lite']['rpm']['file']}"
end

if node['fluent-agent-lite']['rpmbuild']['s3']['upload']
  bash "s3upload" do
    user "#{node['fluent-agent-lite']['rpmbuild']['user']}"
    group "#{node['fluent-agent-lite']['rpmbuild']['group']}"
    cwd "#{node['fluent-agent-lite']['rpmbuild']['root_dir']}/RPMS/x86_64"
    code <<-EOC
      s3cmd put #{node['fluent-agent-lite']['rpm']['file']} #{node['fluent-agent-lite']['rpmbuild']['s3']['url']}
    EOC
    not_if "s3cmd ls #{node['fluent-agent-lite']['rpmbuild']['s3']['url']} | grep -q #{node['fluent-agent-lite']['rpm']['file']}"
  end
end
