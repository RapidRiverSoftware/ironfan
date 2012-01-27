#
# Cookbook Name:: hadoop
# Recipe:: jobtracker
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
hadoop_package "jobtracker"

# launch service
service "#{node[:hadoop][:hadoop_handle]}-jobtracker" do
  action    node[:service_states][:hadoop_jobtracker]
  supports :status => true, :restart => true
  ignore_failure true
end

# register with cluster_service_discovery
provide_service ("#{node[:cluster_name]}-jobtracker")
