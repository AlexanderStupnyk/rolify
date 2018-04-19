require "rolify/shared_contexts"
require "rolify/shared_examples/shared_examples_for_add_permission"
require "rolify/shared_examples/shared_examples_for_has_permission"
require "rolify/shared_examples/shared_examples_for_only_has_permission"
require "rolify/shared_examples/shared_examples_for_has_all_permissions"
require "rolify/shared_examples/shared_examples_for_has_any_permission"
require "rolify/shared_examples/shared_examples_for_remove_permission"
require "rolify/shared_examples/shared_examples_for_finders"


shared_examples_for Rolify::Permission do
  before(:all) do
    reset_defaults
    Rolify.dynamic_shortcuts = false
    rolify_options = { :permission_cname => permission_class.to_s }
    rolify_options[:permission_join_table_name] = join_table if defined? join_table
    silence_warnings { user_class.rolify rolify_options }
    permission_class.destroy_all
    Forum.resourcify :permissions, :permission_cname => permission_class.to_s
    Group.resourcify :permissions, :permission_cname => permission_class.to_s
    Organization.resourcify :permissions, :permission_cname => permission_class.to_s
  end

  context "in the Instance level" do
    before(:all) do
      admin = user_class.first
      admin.add_permission :admin
      admin.add_permission :moderator, Forum.first
    end

    subject { user_class.first }

    [ :grant, :add_permission ].each do |method_alias|
      it { should respond_to(method_alias.to_sym).with(1).arguments }
      it { should respond_to(method_alias.to_sym).with(2).arguments }
    end

    it { should respond_to(:has_permission?).with(1).arguments }
    it { should respond_to(:has_permission?).with(2).arguments }

    it { should respond_to(:has_all_permissions?) }
    it { should respond_to(:has_all_permissions?) }

    it { should respond_to(:has_any_permission?) }
    it { should respond_to(:has_any_permission?) }

    [ :has_no_permission, :revoke, :remove_permission ].each do |method_alias|
      it { should respond_to(method_alias.to_sym).with(1).arguments }
      it { should respond_to(method_alias.to_sym).with(2).arguments }
    end

    it { should_not respond_to(:is_admin?) }
    it { should_not respond_to(:is_moderator_of?) }

    describe "#has_permission?" do
      it_should_behave_like "#has_permission?_examples", "String", :to_s
      it_should_behave_like "#has_permission?_examples", "Symbol", :to_sym
    end

    describe "#only_has_permission?" do
      it_should_behave_like "#only_has_permission?_examples", "String", :to_s
      it_should_behave_like "#only_has_permission?_examples", "Symbol", :to_sym
    end

    describe "#has_all_permissions?" do
      it_should_behave_like "#has_all_permissions?_examples", "String", :to_s
      it_should_behave_like "#has_all_permissions?_examples", "Symbol", :to_sym
    end

    describe "#has_any_permission?" do
      it_should_behave_like "#has_any_permission?_examples", "String", :to_s
      it_should_behave_like "#has_any_permission?_examples", "Symbol", :to_sym
    end

    describe "#has_no_permission" do
      it_should_behave_like "#remove_permission_examples", "String", :to_s
      it_should_behave_like "#remove_permission_examples", "Symbol", :to_sym
    end
  end

  context "with a new instance" do
    let(:user) { user_class.new }

    before do
      user.add_permission :admin
      user.add_permission :moderator, Forum.first
    end

    subject { user }

    it { should have_permission :admin }
    # it { should have_permission :admin, Forum }
    # it { should have_permission :admin, :any }
    # it { should have_permission :moderator, Forum.first }
    # it { should have_permission :moderator, :any }
    # it { should_not have_permission :moderator }
    # it { should_not have_permission :moderator, Forum }
    it { subject.has_any_permission?(:admin).should be_truthy }
  end

  context "on the Class level ", :scope => :mixed do
    it_should_behave_like :finders, "String", :to_s
    it_should_behave_like :finders, "Symbol", :to_sym
  end
end
