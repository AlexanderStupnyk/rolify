require "rolify/configure"

module Rolify
  module Dynamic
    def define_dynamic_method(permission_name, resource)
      class_eval do 
        define_method("is_#{permission_name}?".to_sym) do
          has_permission?("#{permission_name}")
        end if !method_defined?("is_#{permission_name}?".to_sym) && self.adapter.where_strict(self.permission_class, name: permission_name).exists?

        define_method("is_#{permission_name}_of?".to_sym) do |arg|
          has_permission?("#{permission_name}", arg)
        end if !method_defined?("is_#{permission_name}_of?".to_sym) && resource && self.adapter.where_strict(self.permission_class, name: permission_name, resource: resource).exists?
      end
    end
  end
end
