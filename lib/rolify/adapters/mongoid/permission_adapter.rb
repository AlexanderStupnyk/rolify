require 'rolify/adapters/base'

module Rolify
  module Adapter
    class PermissionAdapter < PermissionAdapterBase
      def where(relation, *args)
        conditions = build_conditions(relation, args)
        relation.any_of(*conditions)
      end

      def where_strict(relation, args)
        return relation.where(:name => args[:name]) if args[:resource].blank?
        resource = if args[:resource].is_a?(Class)
                     {class: args[:resource].to_s, id: nil}
                   else
                     {class: args[:resource].class.name, id: args[:resource].id}
                   end

        relation.where(:name => args[:name], :resource_type => resource[:class], :resource_id => resource[:id])
      end

      def find_cached(relation, args)
        resource_id = (args[:resource].nil? || args[:resource].is_a?(Class) || args[:resource] == :any) ? nil : args[:resource].id
        resource_type = args[:resource].is_a?(Class) ? args[:resource].to_s : args[:resource].class.name

        return relation.find_all { |permission| permission.name == args[:name].to_s } if args[:resource] == :any

        relation.find_all do |permission|
          (permission.name == args[:name].to_s && permission.resource_type == nil && permission.resource_id == nil) ||
          (permission.name == args[:name].to_s && permission.resource_type == resource_type && permission.resource_id == nil) ||
          (permission.name == args[:name].to_s && permission.resource_type == resource_type && permission.resource_id == resource_id)
        end
      end

      def find_cached_strict(relation, args)
        resource_id = (args[:resource].nil? || args[:resource].is_a?(Class)) ? nil : args[:resource].id
        resource_type = args[:resource].is_a?(Class) ? args[:resource].to_s : args[:resource].class.name

        relation.find_all do |permission|
          permission.resource_id == resource_id && permission.resource_type == resource_type && permission.name == args[:name].to_s
        end
      end

      def find_or_create_by(permission_name, resource_type = nil, resource_id = nil)
        self.permission_class.find_or_create_by(:name => permission_name,
                                          :resource_type => resource_type,
                                          :resource_id => resource_id)
      end

      def add(relation, permission)
        relation.permissions << permission
      end

      def remove(relation, permission_name, resource = nil)
        #permissions = { :name => permission_name }
        #permissions.merge!({:resource_type => (resource.is_a?(Class) ? resource.to_s : resource.class.name)}) if resource
        #permissions.merge!({ :resource_id => resource.id }) if resource && !resource.is_a?(Class)
        #permissions_to_remove = relation.permissions.where(permissions)
        #permissions_to_remove.each do |permission|
        #  # Deletion in n-n relations is unreliable. Sometimes it works, sometimes not.
        #  # So, this does not work all the time: `relation.permissions.delete(permission)`
        #  # @see http://stackoverflow.com/questions/9132596/rails3-mongoid-many-to-many-relation-and-delete-operation
        #  # We instead remove ids from the Permission object and the relation object.
        #  relation.permission_ids.delete(permission.id)
        #  permission.send((user_class.to_s.underscore + '_ids').to_sym).delete(relation.id)
        #
        #  permission.destroy if permission.send(user_class.to_s.tableize.to_sym).empty?
        #end
        cond = { :name => permission_name }
        cond[:resource_type] = (resource.is_a?(Class) ? resource.to_s : resource.class.name) if resource
        cond[:resource_id] = resource.id if resource && !resource.is_a?(Class)
        permissions = relation.permissions.where(cond)
        permissions.each do |permission|
          relation.permissions.delete(permission)
          permission.send(ActiveSupport::Inflector.demodulize(user_class).tableize.to_sym).delete(relation)
          if Rolify.remove_permission_if_empty && permission.send(ActiveSupport::Inflector.demodulize(user_class).tableize.to_sym).empty?
            permission.destroy
          end
        end if permissions
        permissions
      end

      def exists?(relation, column)
        relation.where(column.to_sym.ne => nil)
      end

      def scope(relation, conditions)
        permissions = where(permission_class, conditions).map { |permission| permission.id }
        return [] if permissions.size.zero?
        query = relation.any_in(:permission_ids => permissions)
        query
      end

      def all_except(user, excluded_obj)
        user.not_in(_id: excluded_obj.to_a)
      end

      private

      def build_conditions(relation, args)
        conditions = []
        args.each do |arg|
          if arg.is_a? Hash
            query = build_query(arg[:name], arg[:resource])
          elsif arg.is_a?(String) || arg.is_a?(Symbol)
            query = build_query(arg)
          else
            raise ArgumentError, "Invalid argument type: only hash or string or symbol allowed"
          end
          conditions += query
        end
        conditions
      end

      def build_query(permission, resource = nil)
        return [{ :name => permission }] if resource == :any
        query = [{ :name => permission, :resource_type => nil, :resource_id => nil }]
        if resource
          query << { :name => permission, :resource_type => (resource.is_a?(Class) ? resource.to_s : resource.class.name), :resource_id => nil }
          if !resource.is_a? Class
            query << { :name => permission, :resource_type => resource.class.name, :resource_id => resource.id }
          end
        end
        query
      end
    end
  end
end
