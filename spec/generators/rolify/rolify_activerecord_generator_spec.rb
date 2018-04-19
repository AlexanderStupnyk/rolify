require 'generators_helper'

# Generators are not automatically loaded by Rails
require 'generators/rolify/rolify_generator'

describe Rolify::Generators::RolifyGenerator, :if => ENV['ADAPTER'] == 'active_record' do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../tmp", __FILE__)
  teardown :cleanup_destination_root

  let(:adapter) { 'SQLite3Adapter' }
  before {
    prepare_destination
  }

  def cleanup_destination_root
    FileUtils.rm_rf destination_root
  end

  describe 'specifying only Permission class name' do
    before(:all) { arguments %w(Permission) }

    before {
      allow(ActiveRecord::Base).to receive_message_chain(
        'connection.class.to_s.demodulize') { adapter }
      capture(:stdout) {
        generator.create_file "app/models/user.rb" do
          <<-RUBY
          class User < ActiveRecord::Base
          end
          RUBY
        end
      }
      require File.join(destination_root, "app/models/user.rb")
      run_generator
    }

    describe 'config/initializers/rolify.rb' do
      subject { file('config/initializers/rolify.rb') }
      it { should exist }
      it { should contain "Rolify.configure do |config|"}
      it { should contain "# config.use_dynamic_shortcuts" }
      it { should contain "# config.use_mongoid" }
    end

    describe 'app/models/permission.rb' do
      subject { file('app/models/permission.rb') }
      it { should exist }
      it do
        if Rails::VERSION::MAJOR < 5
          should contain "class Permission < ActiveRecord::Base"
        else
          should contain "class Permission < ApplicationRecord"
        end
      end
      it { should contain "has_and_belongs_to_many :users, :join_table => :users_permissions" }
      it do
        if Rails::VERSION::MAJOR < 5
          should contain "belongs_to :resource,\n"
                          "           :polymorphic => true"
        else
          should contain "belongs_to :resource,\n"
                          "           :polymorphic => true,\n"
                          "           :optional => true"
        end
      end
      it { should contain "belongs_to :resource,\n"
                          "           :polymorphic => true,\n"
                          "           :optional => true"
      }
      it { should contain "validates :resource_type,\n"
                          "          :inclusion => { :in => Rolify.resource_types },\n"
                          "          :allow_nil => true" }
    end

    describe 'app/models/user.rb' do
      subject { file('app/models/user.rb') }
      it { should contain /class User < ActiveRecord::Base\n  rolify\n/ }
    end

    describe 'migration file' do
      subject { migration_file('db/migrate/rolify_create_permissions.rb') }

      it { should be_a_migration }
      it { should contain "create_table(:permissions) do" }
      it { should contain "create_table(:users_permissions, :id => false) do" }

      context 'mysql2' do
        let(:adapter) { 'Mysql2Adapter' }

        it { expect(subject).to contain('add_index(:permissions, :name)') }
      end

      context 'sqlite3' do
        let(:adapter) { 'SQLite3Adapter' }

        it { expect(subject).to contain('add_index(:permissions, :name)') }
      end

      context 'pg' do
        let(:adapter) { 'PostgreSQLAdapter' }

        it { expect(subject).not_to contain('add_index(:permissions, :name)') }
      end
    end
  end

  describe 'specifying User and Permission class names' do
    before(:all) { arguments %w(AdminPermission AdminUser) }

    before {
      allow(ActiveRecord::Base).to receive_message_chain(
        'connection.class.to_s.demodulize') { adapter }
      capture(:stdout) {
        generator.create_file "app/models/admin_user.rb" do
          "class AdminUser < ActiveRecord::Base\nend"
        end
      }
      require File.join(destination_root, "app/models/admin_user.rb")
      run_generator
    }

    describe 'config/initializers/rolify.rb' do
      subject { file('config/initializers/rolify.rb') }

      it { should exist }
      it { should contain "Rolify.configure(\"AdminPermission\") do |config|"}
      it { should contain "# config.use_dynamic_shortcuts" }
      it { should contain "# config.use_mongoid" }
    end

    describe 'app/models/admin_permission.rb' do
      subject { file('app/models/admin_permission.rb') }

      it { should exist }
      it do
        if Rails::VERSION::MAJOR < 5
          should contain "class AdminPermission < ActiveRecord::Base"
        else
          should contain "class AdminPermission < ApplicationRecord"
        end
      end
      it { should contain "has_and_belongs_to_many :admin_users, :join_table => :admin_users_admin_permissions" }
      it { should contain "belongs_to :resource,\n"
                          "           :polymorphic => true,\n"
                          "           :optional => true"
      }
    end

    describe 'app/models/admin_user.rb' do
      subject { file('app/models/admin_user.rb') }

      it { should contain /class AdminUser < ActiveRecord::Base\n  rolify :permission_cname => 'AdminPermission'\n/ }
    end

    describe 'migration file' do
      subject { migration_file('db/migrate/rolify_create_admin_permissions.rb') }

      it { should be_a_migration }
      it { should contain "create_table(:admin_permissions)" }
      it { should contain "create_table(:admin_users_admin_permissions, :id => false) do" }

      context 'mysql2' do
        let(:adapter) { 'Mysql2Adapter' }

        it { expect(subject).to contain('add_index(:admin_permissions, :name)') }
      end

      context 'sqlite3' do
        let(:adapter) { 'SQLite3Adapter' }

        it { expect(subject).to contain('add_index(:admin_permissions, :name)') }
      end

      context 'pg' do
        let(:adapter) { 'PostgreSQLAdapter' }

        it { expect(subject).not_to contain('add_index(:admin_permissions, :name)') }
      end
    end
  end

  describe 'specifying namespaced User and Permission class names' do
    before(:all) { arguments %w(Admin::Permission Admin::User) }

    before {
      allow(ActiveRecord::Base).to receive_message_chain(
        'connection.class.to_s.demodulize') { adapter }
      capture(:stdout) {
        generator.create_file "app/models/admin/user.rb" do
          <<-RUBY
          module Admin
            class User < ActiveRecord::Base
              self.table_name_prefix = 'admin_'
            end
          end
          RUBY
        end
      }
      require File.join(destination_root, "app/models/admin/user.rb")
      run_generator
    }

    describe 'config/initializers/rolify.rb' do
      subject { file('config/initializers/rolify.rb') }

      it { should exist }
      it { should contain "Rolify.configure(\"Admin::Permission\") do |config|"}
      it { should contain "# config.use_dynamic_shortcuts" }
      it { should contain "# config.use_mongoid" }
    end

    describe 'app/models/admin/permission.rb' do
      subject { file('app/models/admin/permission.rb') }

      it { should exist }
      it do
        if Rails::VERSION::MAJOR < 5
          should contain "class Admin::Permission < ActiveRecord::Base"
        else
          should contain "class Admin::Permission < ApplicationRecord"
        end
      end
      it { should contain "has_and_belongs_to_many :admin_users, :join_table => :admin_users_admin_permissions" }
      it { should contain "belongs_to :resource,\n"
                          "           :polymorphic => true,\n"
                          "           :optional => true"
      }
    end

    describe 'app/models/admin/user.rb' do
      subject { file('app/models/admin/user.rb') }

      it { should contain /class User < ActiveRecord::Base\n  rolify :permission_cname => 'Admin::Permission'\n/ }
    end

    describe 'migration file' do
      subject { migration_file('db/migrate/rolify_create_admin_permissions.rb') }

      it { should be_a_migration }
      it { should contain "create_table(:admin_permissions)" }
      it { should contain "create_table(:admin_users_admin_permissions, :id => false) do" }

      context 'mysql2' do
        let(:adapter) { 'Mysql2Adapter' }

        it { expect(subject).to contain('add_index(:admin_permissions, :name)') }
      end

      context 'sqlite3' do
        let(:adapter) { 'SQLite3Adapter' }

        it { expect(subject).to contain('add_index(:admin_permissions, :name)') }
      end

      context 'pg' do
        let(:adapter) { 'PostgreSQLAdapter' }

        it { expect(subject).not_to contain('add_index(:admin_permissions, :name)') }
      end
    end
  end
end
