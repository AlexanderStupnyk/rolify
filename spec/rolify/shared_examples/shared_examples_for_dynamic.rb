shared_examples_for Rolify::Dynamic do
  before(:all) do
    Rolify.dynamic_shortcuts = true
    permission_class.destroy_all
    rolify_options = { :permission_cname => permission_class.to_s }
    rolify_options[:permission_join_table_name] = join_table if defined? join_table
    silence_warnings { user_class.rolify rolify_options }
    Forum.resourcify :permissions, :permission_cname => permission_class.to_s
    Group.resourcify :permissions, :permission_cname => permission_class.to_s
  end

  context "using a global permission" do
    subject do
      admin = user_class.first
      admin.add_permission :admin
      admin.add_permission :moderator, Forum.first
      admin.add_permission :solo
      admin
    end

    it { should respond_to(:is_admin?).with(0).arguments }
    it { should respond_to(:is_moderator_of?).with(1).arguments }
    it { should_not respond_to(:is_god?) }

    it { subject.is_admin?.should be(true) }
    it { subject.is_admin?.should be(true) }
    it { subject.is_admin?.should be(true) }

    context "removing the permission on the last user having it" do
      before do
        subject.remove_permission :solo
      end

      it { should_not respond_to(:is_solo?) }
      it { subject.is_solo?.should be(false) }
    end
  end

  context "using a resource scoped permission" do
    subject do
      moderator = user_class.where(:login => "moderator").first
      moderator.add_permission :moderator, Forum.first
      moderator.add_permission :sole_mio, Forum.last
      moderator
    end

    it { should respond_to(:is_moderator?).with(0).arguments }
    it { should respond_to(:is_moderator_of?).with(1).arguments }
    it { should_not respond_to(:is_god?) }
    it { should_not respond_to(:is_god_of?) }

    it { subject.is_moderator?.should be(false) }
    it { subject.is_moderator_of?(Forum).should be(false) }
    it { subject.is_moderator_of?(Forum.first).should be(true) }
    it { subject.is_moderator_of?(Forum.last).should be(false) }
    it { subject.is_moderator_of?(Group).should be(false) }
    it { subject.is_moderator_of?(Group.first).should be(false) }
    it { subject.is_moderator_of?(Group.last).should be(false) }

    context "removing the permission on the last user having it" do
      before do
        subject.remove_permission :sole_mio, Forum.last
      end

      it { should_not respond_to(:is_sole_mio?) }
      it { subject.is_sole_mio?.should be(false) }
    end
  end

  context "using a class scoped permission" do
    subject do
      manager = user_class.where(:login => "god").first
      manager.add_permission :manager, Forum
      manager.add_permission :only_me, Forum
      manager
    end

    it { should respond_to(:is_manager?).with(0).arguments }
    it { should respond_to(:is_manager_of?).with(1).arguments }
    it { should_not respond_to(:is_god?) }
    it { should_not respond_to(:is_god_of?) }

    it { subject.is_manager?.should be(false) }
    it { subject.is_manager_of?(Forum).should be(true) }
    it { subject.is_manager_of?(Forum.first).should be(true) }
    it { subject.is_manager_of?(Forum.last).should be(true) }
    it { subject.is_manager_of?(Group).should be(false) }
    it { subject.is_manager_of?(Group.first).should be(false) }
    it { subject.is_manager_of?(Group.last).should be(false) }

    context "removing the permission on the last user having it" do
      before do
        subject.remove_permission :only_me, Forum
      end

      it { should_not respond_to(:is_only_me?) }
      it { subject.is_only_me?.should be(false) }
    end
  end

  context "if the permission doesn't exist in the database" do

    subject { user_class.first }

    context "using a global permission" do
      before(:all) do
        other_guy = user_class.last
        other_guy.add_permission :superman
      end

      it { should respond_to(:is_superman?).with(0).arguments }
      it { should_not respond_to(:is_superman_of?) }
      it { should_not respond_to(:is_god?) }

      it { subject.is_superman?.should be(false) }
      it { subject.is_god?.should be(false) }
    end

    context "using a resource scope permission" do
      before(:all) do
        other_guy = user_class.last
        other_guy.add_permission :batman, Forum.first
      end

      it { should respond_to(:is_batman?).with(0).arguments }
      it { should respond_to(:is_batman_of?).with(1).arguments }
      it { should_not respond_to(:is_god?) }
      it { should_not respond_to(:is_god_of?) }

      it { subject.is_batman?.should be(false) }
      it { subject.is_batman_of?(Forum).should be(false) }
      it { subject.is_batman_of?(Forum.first).should be(false) }
      it { subject.is_batman_of?(Forum.last).should be(false) }
      it { subject.is_batman_of?(Group).should be(false) }
      it { subject.is_batman_of?(Group.first).should be(false) }
      it { subject.is_batman_of?(Group.last).should be(false) }

      it { subject.is_god?.should be(false) }
      it { subject.is_god_of?(Forum).should be(false) }
      it { subject.is_god_of?(Forum.first).should be(false) }
      it { subject.is_god_of?(Forum.last).should be(false) }
      it { subject.is_god_of?(Group).should be(false) }
      it { subject.is_god_of?(Group.first).should be(false) }
      it { subject.is_god_of?(Group.last).should be(false) }
    end
  end
end
