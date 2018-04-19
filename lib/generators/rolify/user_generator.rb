require 'rails/generators/migration'
require 'active_support/core_ext'

module Rolify
  module Generators
    class UserGenerator < Rails::Generators::NamedBase
      argument :permission_cname, :type => :string, :default => "Permission"
      class_option :orm, :type => :string, :default => "active_record"
      
      desc "Inject rolify method in the User class."

      def inject_user_content
        inject_into_file(model_path, :after => inject_rolify_method) do
          "  rolify#{permission_association}\n"
        end
      end
      
      def inject_rolify_method
        if options.orm == :active_record
          /class #{class_name.camelize}\n|class #{class_name.camelize} .*\n|class #{class_name.demodulize.camelize}\n|class #{class_name.demodulize.camelize} .*\n/
        else
          /include Mongoid::Document\n|include Mongoid::Document .*\n/
        end
      end
      
      def model_path
        File.join("app", "models", "#{file_path}.rb")
      end
      
      def permission_association
        if permission_cname != "Permission"
          " :permission_cname => '#{permission_cname.camelize}'"
        else
          ""
        end
      end
    end
  end
end
