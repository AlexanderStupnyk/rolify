require 'rolify/adapters/base'

module Rolify
  module Adapter
    class ResourceAdapter < ResourceAdapterBase

      def find_permissions(permission_name, relation, user)
        permissions = user && (user != :any) ? user.permissions : self.permission_class
        permissions = permissions.where(:resource_type.in => self.relation_types_for(relation))
        permissions = permissions.where(:name => permission_name.to_s) if permission_name && (permission_name != :any)
        permissions
      end

      def resources_find(permissions_table, relation, permission_name)
        permissions = permissions_table.classify.constantize.where(:name.in => Array(permission_name), :resource_type.in => self.relation_types_for(relation))
        resources = []
        permissions.each do |permission|
          if permission.resource_id.nil?
            resources += relation.all
          else
            resources << permission.resource
          end
        end
        resources.compact.uniq
      end

      def in(resources, user, permission_names)
        permissions = user.permissions.where(:name.in => Array(permission_names))
        return [] if resources.empty? || permissions.empty?
        resources.delete_if { |resource| (resource.applied_permissions & permissions).empty? }
        resources
      end

      def applied_permissions(relation, children)
        if children
          relation.permission_class.where(:resource_type.in => self.relation_types_for(relation), :resource_id => nil)
        else
          relation.permission_class.where(:resource_type => relation.to_s, :resource_id => nil)
        end
      end

      def all_except(resource, excluded_obj)
        resource.not_in(_id: excluded_obj.to_a)
      end

    end
  end
end