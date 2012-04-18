#
# Author:: Chris Howe (<howech@infochimps.com>)
# Copyright:: Copyright (c) 2011 Infochimps, Inc
# License:: Apache License, Version 2.0
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

require File.expand_path('ironfan_script', File.dirname(__FILE__))

class Chef
  class Knife
    class ClusterKill < Ironfan::Script
      import_banner_and_options(Ironfan::Script)

      option :kill_bogus,
        :long        => "--kill-bogus",
        :description => "Kill bogus servers (ones that exist, but are not defined in the clusters file)",
        :boolean     => true,
        :default     => false
      option :cloud,
        :long        => '--[no-]cloud',
        :description => "Kill machines from cloud (default is yes, terminate machines; use --no-cloud to skip)",
        :boolean     => true,
        :default     => true
      option :chef,
        :long        => "--[no-]chef",
        :description => "Delete the chef node and client (default is yes, delete chef objects; use --no-chef to skip)",
        :boolean     => true,
        :default     => true

      # BEGIN for-vsphere
      def run
        load_ironfan
        die(banner) if @name_args.empty?
        configure_dry_run

        # initialize IaasProvider
        Iaas::IaasProvider.init(JSON.parse(File.read(config[:from_file])))

        target = get_slice(*@name_args)
        display(target)

        section("Deleting Cloud Machines")
        task = Ironfan.fog_connection.delete_cluster
        while !task.finish?
          Chef::Log.debug("progress of deleting cluster: #{task.get_progress.inspect}")
          sleep(5)
        end
        Chef::Log.debug("result of deleting cluster: #{task.get_progress.result.servers.inspect}")
      
        section("Deleting Chef Nodes")
        target.select(&:in_chef? ).delete_chef
      end
      # END

      def relevant?(server)
        server.killable?
      end

      # Execute every last mf'ing one of em
      def perform_execution(target)
        if config[:cloud]
          section("Killing Cloud Machines")
          target.select(&:in_cloud?).destroy
        end

        if config[:chef]
          section("Killing Chef")
          target.select(&:in_chef? ).delete_chef
        end
      end

      def display(target, *args, &block)
        super
        ui.info Formatador.display_line("[red]Bogus servers detected[reset]: [blue]#{target.bogus_servers.map(&:fullname).inspect}[reset]") unless target.bogus_servers.empty?
      end

      def confirm_execution(target)
        delete_message = [
          (((!config[:chef])   || target.chef_nodes.empty?)  ? nil : "#{target.chef_nodes.length} chef nodes"),
          (((!config[:cloud])  || target.fog_servers.empty?) ? nil : "#{target.fog_servers.length} fog servers") ].compact.join(" and ")
        confirm_or_exit("Are you absolutely certain that you want to delete #{delete_message}? (Type 'Yes' to confirm) ", 'Yes')
      end

    end
  end
end
