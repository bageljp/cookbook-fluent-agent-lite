#
# Cookbook Name:: fluent-agent-lite
# Recipe:: default
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

case node['fluent-agent-lite']['install_flavor']
when 'rpm'
  # rpm
  remote_file "/usr/local/src/#{node['fluent-agent-lite']['rpm']['file']}" do
    owner "root"
    group "root"
    mode 00644
    source "#{node['fluent-agent-lite']['rpm']['url']}"
  end

  package "fluent-agent-lite" do
    action :install
    provider Chef::Provider::Package::Rpm
    source "/usr/local/src/#{node['fluent-agent-lite']['rpm']['file']}"
  end
end

template "/etc/fluent-agent-lite.conf" do
  owner "root"
  group "root"
  mode 00644
  notifies :restart, "service[fluent-agent-lite]"
end

template "/etc/fluent-agent-lite.logs" do
  owner "root"
  group "root"
  mode 00644
  notifies :restart, "service[fluent-agent-lite]"
end

template "/etc/logrotate.d/fluent-agent-lite" do
  owner "root"
  group "root"
  mode 00644
  source "fluent-agent-lite.logrotate.erb"
end

service "fluent-agent-lite" do
  supports :status => true, :restart => true, :reload => false
  action [ :enable, :start ]
end

