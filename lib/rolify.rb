require 'rolify/adapters/base'
require 'rolify/configure'
require 'rolify/dynamic'
require 'rolify/railtie' if defined?(Rails)
require 'rolify/resource'
require 'rolify/permission'

module Rolify
  extend Configure

  attr_accessor :permission_cname, :adapter, :resource_adapter, :permission_join_table_name, :permission_table_name, :strict_rolify
  @@resource_types = []

  def rolify(options = {})
    include Permission
    extend Dynamic if Rolify.dynamic_shortcuts

    options.reverse_merge!({:permission_cname => 'Permission'})
    self.permission_cname = options[:permission_cname]
    self.permission_table_name = self.permission_cname.tableize.gsub(/\//, "_")

    default_join_table = "#{self.to_s.tableize.gsub(/\//, "_")}_#{self.permission_table_name}"
    options.reverse_merge!({:permission_join_table_name => default_join_table})
    self.permission_join_table_name = options[:permission_join_table_name]

    rolify_options = { :class_name => options[:permission_cname].camelize }
    rolify_options.merge!({ :join_table => self.permission_join_table_name }) if Rolify.orm == "active_record"
    rolify_options.merge!(options.reject{ |k,v| ![ :before_add, :after_add, :before_remove, :after_remove, :inverse_of ].include? k.to_sym })

    has_and_belongs_to_many :permissions, rolify_options

    self.adapter = Rolify::Adapter::Base.create("permission_adapter", self.permission_cname, self.name)

    #use strict permissions
    self.strict_rolify = true if options[:strict]
  end

  def adapter
    return self.superclass.adapter unless self.instance_variable_defined? '@adapter'
    @adapter
  end

  def resourcify(association_name = :permissions, options = {})
    include Resource

    options.reverse_merge!({ :permission_cname => 'Permission', :dependent => :destroy })
    resourcify_options = { :class_name => options[:permission_cname].camelize, :as => :resource, :dependent => options[:dependent] }
    self.permission_cname = options[:permission_cname]
    self.permission_table_name = self.permission_cname.tableize.gsub(/\//, "_")

    has_many association_name, resourcify_options

    self.resource_adapter = Rolify::Adapter::Base.create("resource_adapter", self.permission_cname, self.name)
    @@resource_types << self.name
  end

  def resource_adapter
    return self.superclass.resource_adapter unless self.instance_variable_defined? '@resource_adapter'
    @resource_adapter
  end

  def scopify
    require "rolify/adapters/#{Rolify.orm}/scopes.rb"
    extend Rolify::Adapter::Scopes
  end

  def permission_class
    return self.superclass.permission_class unless self.instance_variable_defined? '@permission_cname'
    self.permission_cname.constantize
  end

  def self.resource_types
    @@resource_types
  end

end
