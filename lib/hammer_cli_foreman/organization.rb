require 'hammer_cli'
require 'foreman_api'
require 'hammer_cli_foreman/formatters'
require 'hammer_cli_foreman/commands'

module HammerCLIForeman

  class Organization < HammerCLI::AbstractCommand

    module SupportTest

      def execute
        if resource_supported?
          super
        else
          output.print_error "The server does not support organizations."
          1
        end
      end

      def resource_supported?
        resource.index
        true
      rescue RestClient::ResourceNotFound => e
        false
      end

    end

    class ListCommand < HammerCLIForeman::ListCommand
      include HammerCLIForeman::Organization::SupportTest
      resource ForemanApi::Resources::Organization, "index"

      heading "Organizations"
      output do
        from "organization" do
          field :id, "Id"
          field :name, "Name"
        end
      end

      apipie_options
    end


    class InfoCommand < HammerCLIForeman::InfoCommand
      include HammerCLIForeman::Organization::SupportTest
      resource ForemanApi::Resources::Organization, "show"

      heading "Organization info"
      output ListCommand.output_definition do
        from "organization" do
          field :created_at, "Created at", &HammerCLIForeman::Formatters.method(:date_formatter)
          field :updated_at, "Updated at", &HammerCLIForeman::Formatters.method(:date_formatter)
        end
      end

    end


    class CreateCommand < HammerCLIForeman::CreateCommand
      include HammerCLIForeman::Organization::SupportTest

      success_message "Organization created"
      failure_message "Could not create the organization"
      resource ForemanApi::Resources::Organization, "create"

      apipie_options
    end


    class UpdateCommand < HammerCLIForeman::UpdateCommand
      include HammerCLIForeman::Organization::SupportTest

      success_message "Organization updated"
      failure_message "Could not update the organization"
      resource ForemanApi::Resources::Organization, "update"

      apipie_options
    end


    class DeleteCommand < HammerCLIForeman::DeleteCommand
      include HammerCLIForeman::Organization::SupportTest

      success_message "Organization deleted"
      failure_message "Could not delete the organization"
      resource ForemanApi::Resources::Organization, "destroy"

      apipie_options
    end

    subcommand "list", "List organizations.", HammerCLIForeman::Organization::ListCommand
    subcommand "info", "Detailed info about an organization.", HammerCLIForeman::Organization::InfoCommand
    subcommand "create", "Create new organization.", HammerCLIForeman::Organization::CreateCommand
    subcommand "update", "Update an organization.", HammerCLIForeman::Organization::UpdateCommand
    subcommand "delete", "Delete an organization.", HammerCLIForeman::Organization::DeleteCommand
  end

end

HammerCLI::MainCommand.subcommand 'organization', "Manipulate Foreman's organizations.", HammerCLIForeman::Organization
