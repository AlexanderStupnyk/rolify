require 'rolify/adapters/base'

module Rolify
  module Adapter
    class ResourceAdapter < ResourceAdapterBase
      def find_permissions(permission_name, relation, user)
        permissions = user && (user != :any) ? user.permissions : self.permission_class
        permissions = permissions.where('resource_type IN (?)', self.relation_types_for(relation))
        permissions = permissions.where(:name => permission_name.to_s) if permission_name && (permission_name != :any)
        permissions
      end

      def resources_find(permissions_table, relation, permission_name)
        klasses   = self.relation_types_for(relation)
        relations = klasses.inject('') do |str, klass|
          str = "#{str}'#{klass.to_s}'"
          str << ', ' unless klass == klasses.last
          str
        end

        resources = relation.joins("INNER JOIN #{quote_table(permissions_table)} ON #{quote_table(permissions_table)}.resource_type IN (#{relations}) AND
                                    (#{quote_table(permissions_table)}.resource_id IS NULL OR #{quote_table(permissions_table)}.resource_id = #{quote_table(relation.table_name)}.#{quote_column(relation.primary_key)})")
        resources = resources.where("#{quote_table(permissions_table)}.name IN (?) AND #{quote_table(permissions_table)}.resource_type IN (?)", Array(permission_name), klasses)
        resources = resources.select("#{quote_table(relation.table_name)}.*")
        resources
      end

      def in(relation, user, permission_names)
        permissions = user.permissions.where(:name => permission_names).select("#{quote_table(permission_class.table_name)}.#{quote_column(permission_class.primary_key)}")
        relation.where("#{quote_table(permission_class.table_name)}.#{quote_column(permission_class.primary_key)} IN (?) AND ((#{quote_table(permission_class.table_name)}.resource_id = #{quote_table(relation.table_name)}.#{quote_column(relation.primary_key)}) OR (#{quote_table(permission_class.table_name)}.resource_id IS NULL))", permissions)
      end

      def applied_permissions(relation, children)
        if children
          relation.permission_class.where('resource_type IN (?) AND resource_id IS NULL', self.relation_types_for(relation))
        else
          relation.permission_class.where('resource_type = ? AND resource_id IS NULL', relation.to_s)
        end
      end

      def all_except(resource, excluded_obj)
        prime_key = resource.primary_key.to_sym
        resource.where(prime_key => (resource.all - excluded_obj).map(&prime_key))
      end

      private

      def quote_column(column)
        ActiveRecord::Base.connection.quote_column_name column
      end

      def quote_table(table)
        ActiveRecord::Base.connection.quote_table_name table
      end

    end
  end
end
