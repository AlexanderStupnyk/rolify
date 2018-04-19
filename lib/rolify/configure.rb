module Rolify
  module Configure
    @@dynamic_shortcuts = false
    @@orm = "active_record"
    @@remove_permission_if_empty = true

    def configure(*permission_cnames)
      return if !sanity_check(permission_cnames)
      yield self if block_given?
    end

    def dynamic_shortcuts
      @@dynamic_shortcuts
    end

    def dynamic_shortcuts=(is_dynamic)
      @@dynamic_shortcuts = is_dynamic
    end

    def orm
      @@orm
    end

    def orm=(orm)
      @@orm = orm
    end

    def use_mongoid
      self.orm = "mongoid"
    end

    def use_dynamic_shortcuts
      return if !sanity_check([])
      self.dynamic_shortcuts = true
    end

    def use_defaults
      configure do |config|
        config.dynamic_shortcuts = false
        config.orm = "active_record"
      end
    end

    def remove_permission_if_empty=(is_remove)
      @@remove_permission_if_empty = is_remove
    end

    def remove_permission_if_empty
      @@remove_permission_if_empty
    end

    private

    def sanity_check(permission_cnames)
      return true if ARGV.reduce(nil) { |acc,arg| arg =~ /assets:/ if acc.nil? } == 0

      permission_cnames.each do |permission_cname|
        permission_class = permission_cname.constantize
        if permission_class.superclass.to_s == "ActiveRecord::Base" && permission_table_missing?(permission_class)
          warn "[WARN] table '#{permission_cname}' doesn't exist. Did you run the migration? Ignoring rolify config."
          return false
        end
      end
      true
    end

    def permission_table_missing?(permission_class)
      !permission_class.table_exists?
    rescue ActiveRecord::NoDatabaseError
      true
    end

  end
end
