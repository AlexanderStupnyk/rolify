module Rolify
  module Adapter
    class Base
      def initialize(permission_cname, user_cname)
        @permission_cname = permission_cname
        @user_cname = user_cname
      end

      def permission_class
        @permission_cname.constantize
      end
      
      def user_class
        @user_cname.constantize
      end
      
      def permission_table
        permission_class.table_name
      end
      
      def self.create(adapter, permission_cname, user_cname)
        load "rolify/adapters/#{Rolify.orm}/#{adapter}.rb"
        load "rolify/adapters/#{Rolify.orm}/scopes.rb"
        Rolify::Adapter.const_get(adapter.camelize.to_sym).new(permission_cname, user_cname)
      end

      def relation_types_for(relation)
        relation.descendants.map(&:to_s).push(relation.to_s)
      end
    end

    class PermissionAdapterBase < Adapter::Base
      def where(relation, args)
        raise NotImplementedError.new("You must implement where")
      end

      def find_or_create_by(permission_name, resource_type = nil, resource_id = nil)
        raise NotImplementedError.new("You must implement find_or_create_by")
      end

      def add(relation, permission_name, resource = nil)
        raise NotImplementedError.new("You must implement add")
      end

      def remove(relation, permission_name, resource = nil)
        raise NotImplementedError.new("You must implement delete")
      end

      def exists?(relation, column)
        raise NotImplementedError.new("You must implement exists?")
      end
    end

    class ResourceAdapterBase < Adapter::Base
      def resources_find(permissions_table, relation, permission_name)
        raise NotImplementedError.new("You must implement resources_find")
      end

      def in(resources, permissions)
        raise NotImplementedError.new("You must implement in")
      end

    end
  end
end