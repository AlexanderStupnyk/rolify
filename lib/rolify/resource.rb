module Rolify
  module Resource
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def find_permissions(permission_name = nil, user = nil)
        self.resource_adapter.find_permissions(permission_name, self, user)
      end

      def with_permission(permission_name, user = nil)
        if permission_name.is_a? Array
          permission_name.map!(&:to_s)
        else
          permission_name = permission_name.to_s
        end

        resources = self.resource_adapter.resources_find(self.permission_table_name, self, permission_name) #.map(&:id)
        user ? self.resource_adapter.in(resources, user, permission_name) : resources
      end
      alias :with_permissions :with_permission
      alias :find_as :with_permission
      alias :find_multiple_as :with_permission


      def without_permission(permission_name, user = nil)
        self.resource_adapter.all_except(self, self.find_as(permission_name, user))
      end
      alias :without_permissions :without_permission
      alias :except_as :without_permission
      alias :except_multiple_as :without_permission



      def applied_permissions(children = true)
        self.resource_adapter.applied_permissions(self, children)
      end


      
    end

    def applied_permissions
      #self.permissions + self.class.permission_class.where(:resource_type => self.class.to_s, :resource_id => nil)
      self.permissions + self.class.applied_permissions(true)
    end
  end
end
