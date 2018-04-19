module Rolify
  module Finders
    def with_permission(permission_name, resource = nil)
      self.adapter.scope(self, :name => permission_name, :resource => resource)
    end

    def without_permission(permission_name, resource = nil)
      self.adapter.all_except(self, self.with_permission(permission_name, resource))
    end

    def with_all_permissions(*args)
      users = []
      parse_args(args, users) do |users_to_add|
        users = users_to_add if users.empty?
        users &= users_to_add
        return [] if users.empty?
      end
      users
    end

    def with_any_permission(*args)
      users = []
      parse_args(args, users) do |users_to_add|
        users += users_to_add
      end
      users.uniq
    end
  end
  
  private
  
  def parse_args(args, users, &block)
    args.each do |arg|
      if arg.is_a? Hash
        users_to_add = self.with_permission(arg[:name], arg[:resource])
      elsif arg.is_a?(String) || arg.is_a?(Symbol)
        users_to_add = self.with_permission(arg)
      else
        raise ArgumentError, "Invalid argument type: only hash or string or symbol allowed"
      end
      block.call(users_to_add)
    end
  end
end