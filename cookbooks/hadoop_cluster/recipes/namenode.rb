#
# Cookbook Name:: hadoop
# Recipe:: namenode
#
# Copyright 2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "hadoop_cluster"

# Install
hadoop_package "namenode"

# Set up service
service "#{node[:hadoop][:hadoop_handle]}-namenode" do
  action    node[:service_states][:hadoop_namenode]
  supports :status => true, :restart => true
  ignore_failure true
end

# register with cluster_service_discovery
provide_service ("#{node[:cluster_name]}-namenode")

dfs_name_dirs.each do |dir|
  make_hadoop_dir(dir, 'hdfs',   "0700")
end

# lay in a script to boostrap the namenode (initial format, important HDFS dirs, etc
template "/etc/hadoop/conf/bootstrap_hadoop_namenode.sh" do
  owner "root"
  mode "0744"
  variables(hadoop_config_hash)
  source "bootstrap_hadoop_namenode.sh.erb"
end

template "/etc/hadoop/conf/nuke_hdfs_from_orbit_its_the_only_way_to_be_sure.sh" do
  owner "root"
  mode "0744"
  variables(hadoop_config_hash)
  source "nuke_hdfs_from_orbit_its_the_only_way_to_be_sure.sh.erb"
end
