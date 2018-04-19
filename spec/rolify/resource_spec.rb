require "spec_helper"

describe Rolify::Resource do
  before(:all) do
    reset_defaults
    silence_warnings { User.rolify }
    Forum.resourcify
    Group.resourcify
    Team.resourcify
    Organization.resourcify
    Permission.destroy_all
  end

  # Users
  let(:admin)   { User.first }
  let(:tourist) { User.last }
  let(:captain) { User.where(:login => "god").first }

  # permissions
  let!(:forum_permission)      { admin.add_permission(:forum, Forum.first) }
  let!(:godfather_permission)  { admin.add_permission(:godfather, Forum) }
  let!(:group_permission)      { admin.add_permission(:group, Group.last) }
  let!(:grouper_permission)    { admin.add_permission(:grouper, Group.first) }
  let!(:tourist_permission)    { tourist.add_permission(:forum, Forum.last) }
  let!(:sneaky_permission)     { tourist.add_permission(:group, Forum.first) }
  let!(:captain_permission)    { captain.add_permission(:captain, Team.first) }
  let!(:player_permission)     { captain.add_permission(:player, Team.last) }
  let!(:company_permission)    { admin.add_permission(:owner, Company.first) }

  describe ".find_multiple_as" do
    subject { Group }

    it { should respond_to(:find_permissions).with(1).arguments }
    it { should respond_to(:find_permissions).with(2).arguments }

    context "with a permission name as argument" do
      context "on the Forum class" do
        subject { Forum }

        it "should include Forum instances with forum permission" do
          subject.find_as(:forum).should =~ [ Forum.first, Forum.last ]
        end

        it "should include Forum instances with godfather permission" do
          subject.find_as(:godfather).should =~ Forum.all
        end

        it "should be able to modify the resource", :if => ENV['ADAPTER'] == 'active_record' do
          forum_resource = subject.find_as(:forum).first
          forum_resource.name = "modified name"
          expect { forum_resource.save }.not_to raise_error
        end
      end

      context "on the Group class" do
        subject { Group }

        it "should include Group instances with group permission" do
          subject.find_as(:group).should =~ [ Group.last ]
        end
      end

      context "on a Group instance" do
        subject { Group.last }

        it "should ignore nil entries" do
          subject.subgroups.find_as(:group).should =~ [ ]
        end
      end
    end

    context "with an array of permission names as argument" do
      context "on the Group class" do
        subject { Group }

        it "should include Group instances with both group and grouper permissions" do
          subject.find_multiple_as([:group, :grouper]).should =~ [ Group.first, Group.last ]
        end
      end
    end

    context "with a permission name and a user as arguments" do
      context "on the Forum class" do
        subject { Forum }

        it "should get all Forum instances binded to the forum permission and the admin user" do
          subject.find_as(:forum, admin).should =~ [ Forum.first ]
        end

        it "should get all Forum instances binded to the forum permission and the tourist user" do
          subject.find_as(:forum, tourist).should =~ [ Forum.last ]
        end

        it "should get all Forum instances binded to the godfather permission and the admin user" do
          subject.find_as(:godfather, admin).should =~ Forum.all.to_a
        end

        it "should get all Forum instances binded to the godfather permission and the tourist user" do
          subject.find_as(:godfather, tourist).should be_empty
        end

        it "should get Forum instances binded to the group permission and the tourist user" do
          subject.find_as(:group, tourist).should =~ [ Forum.first ]
        end

        it "should not get Forum instances not binded to the group permission and the tourist user" do
          subject.find_as(:group, tourist).should_not include(Forum.last)
        end
      end

      context "on the Group class" do
        subject { Group }

        it "should get all resources binded to the group permission and the admin user" do
          subject.find_as(:group, admin).should =~ [ Group.last ]
        end

        it "should not get resources not binded to the group permission and the admin user" do
          subject.find_as(:group, admin).should_not include(Group.first)
        end
      end
    end

    context "with an array of permission names and a user as arguments" do
      context "on the Forum class" do
        subject { Forum }

        it "should get Forum instances binded to the forum and group permissions and the tourist user" do
          subject.find_multiple_as([:forum, :group], tourist).should =~ [ Forum.first, Forum.last ]
        end

      end

      context "on the Group class" do
        subject { Group }

        it "should get Group instances binded to the group and grouper permissions and the admin user" do
          subject.find_multiple_as([:group, :grouper], admin).should =~ [ Group.first, Group.last ]
        end

      end
    end

    context "with a model not having ID column" do
      subject { Team }

      it "should find Team instance using team_code column" do
        subject.find_multiple_as([:captain, :player], captain).should =~ [ Team.first, Team.last ]
      end
    end

    context "with a resource using STI" do
      subject { Organization }
      it "should find instances of children classes" do
        subject.find_multiple_as(:owner, admin).should =~ [ Company.first ]
      end
    end
  end


  describe ".except_multiple_as" do
    subject { Group }

    it { should respond_to(:find_permissions).with(1).arguments }
    it { should respond_to(:find_permissions).with(2).arguments }

    context "with a permission name as argument" do
      context "on the Forum class" do
        subject { Forum }

        it "should not include Forum instances with forum permission" do
          subject.except_as(:forum).should_not =~ [ Forum.first, Forum.last ]
        end

        it "should not include Forum instances with godfather permission" do
          subject.except_as(:godfather).should be_empty
        end

        it "should be able to modify the resource", :if => ENV['ADAPTER'] == 'active_record' do
          forum_resource = subject.except_as(:forum).first
          forum_resource.name = "modified name"
          expect { forum_resource.save }.not_to raise_error
        end
      end

      context "on the Group class" do
        subject { Group }

        it "should not include Group instances with group permission" do
          subject.except_as(:group).should_not =~ [ Group.last ]
        end
      end

    end

    context "with an array of permission names as argument" do
      context "on the Group class" do
        subject { Group }

        it "should include Group instances without either the group and grouper permissions" do
          subject.except_multiple_as([:group, :grouper]).should_not =~ [ Group.first, Group.last ]
        end
      end
    end

    context "with a permission name and a user as arguments" do
      context "on the Forum class" do
        subject { Forum }

        it "should get all Forum instances the admin user does not have the forum permission" do
          subject.except_as(:forum, admin).should_not =~ [ Forum.first ]
        end

        it "should get all Forum instances the tourist user does not have the forum permission" do
          subject.except_as(:forum, tourist).should_not =~ [ Forum.last ]
        end

        it "should get all Forum instances the admin user does not have the godfather permission" do
          subject.except_as(:godfather, admin).should_not =~ Forum.all
        end

        it "should get all Forum instances tourist user does not have the godfather permission" do
          subject.except_as(:godfather, tourist).should =~ Forum.all
        end

        it "should get Forum instances the tourist user does not have the group permission" do
          subject.except_as(:group, tourist).should_not =~ [ Forum.first ]
        end

        it "should get Forum instances the tourist user does not have the group permission" do
          subject.except_as(:group, tourist).should_not =~ [ Forum.first ]
        end
      end

      context "on the Group class" do
        subject { Group }

        it "should get all resources not bounded to the group permission and the admin user" do
          subject.except_as(:group, admin).should =~ [ Group.first ]
        end

        it "should not get resources bound to the group permission and the admin user" do
          subject.except_as(:group, admin).should include(Group.first)
        end
      end
    end

    context "with an array of permission names and a user as arguments" do
      context "on the Forum class" do
        subject { Forum }

        it "should get Forum instances not bound to the forum and group permissions and the tourist user" do
          subject.except_multiple_as([:forum, :group], tourist).should_not =~ [ Forum.first, Forum.last ]
        end

      end

      context "on the Group class" do
        subject { Group }

        it "should get Group instances binded to the group and grouper permissions and the admin user" do
          subject.except_multiple_as([:group, :grouper], admin).should =~ [ ]
        end

      end
    end

    context "with a model not having ID column" do
      subject { Team }

      it "should find Team instance not using team_code column" do
        subject.except_multiple_as(:captain, captain).should =~ [ Team.last ]
      end
    end

    context "with a resource using STI" do
      subject { Organization }
      it "should exclude instances of children classes with matching" do
        subject.except_as(:owner, admin).should_not =~ [ Company.first ]
      end
    end
  end

  describe ".find_permission" do

    context "without using a permission name parameter" do

      context "on the Forum class" do
        subject { Forum }

        it "should get all permissions binded to a Forum class or instance" do
          subject.find_permissions.to_a.should =~ [ forum_permission, godfather_permission, tourist_permission, sneaky_permission ]
        end

        it "should not get permissions not binded to a Forum class or instance" do
          subject.find_permissions.should_not include(group_permission)
        end

        context "using :any parameter" do
          it "should get all permissions binded to any Forum class or instance" do
            subject.find_permissions(:any, :any).to_a.should =~ [ forum_permission, godfather_permission, tourist_permission, sneaky_permission ]
          end

          it "should not get permissions not binded to a Forum class or instance" do
            subject.find_permissions(:any, :any).should_not include(group_permission)
          end
        end
      end

      context "on the Group class" do
        subject { Group }

        it "should get all permissions binded to a Group class or instance" do
          subject.find_permissions.to_a.should =~ [ group_permission, grouper_permission ]
        end

        it "should not get permissions not binded to a Group class or instance" do
          subject.find_permissions.should_not include(forum_permission, godfather_permission, tourist_permission, sneaky_permission)
        end

        context "using :any parameter" do
          it "should get all permissions binded to Group class or instance" do
            subject.find_permissions(:any, :any).to_a.should =~ [ group_permission, grouper_permission ]
          end

          it "should not get permissions not binded to a Group class or instance" do
            subject.find_permissions(:any, :any).should_not include(forum_permission, godfather_permission, tourist_permission, sneaky_permission)
          end
        end
      end
    end

    context "using a permission name parameter" do
      context "on the Forum class" do
        subject { Forum }

        context "without using a user parameter" do
          it "should get all permissions binded to a Forum class or instance and forum permission name" do
            subject.find_permissions(:forum).should include(forum_permission, tourist_permission)
          end

          it "should not get permissions not binded to a Forum class or instance and forum permission name" do
            subject.find_permissions(:forum).should_not include(godfather_permission, sneaky_permission, group_permission)
          end
        end

        context "using a user parameter" do
          it "should get all permissions binded to any resource" do
            subject.find_permissions(:forum, admin).to_a.should =~ [ forum_permission ]
          end

          it "should not get permissions not binded to the admin user and forum permission name" do
            subject.find_permissions(:forum, admin).should_not include(godfather_permission, tourist_permission, sneaky_permission, group_permission)
          end
        end

        context "using :any parameter" do
          it "should get all permissions binded to any resource with forum permission name" do
            subject.find_permissions(:forum, :any).should include(forum_permission, tourist_permission)
          end

          it "should not get permissions not binded to a resource with forum permission name" do
            subject.find_permissions(:forum, :any).should_not include(godfather_permission, sneaky_permission, group_permission)
          end
        end
      end

      context "on the Group class" do
        subject { Group }

        context "without using a user parameter" do
          it "should get all permissions binded to a Group class or instance and group permission name" do
            subject.find_permissions(:group).should include(group_permission)
          end

          it "should not get permissions not binded to a Forum class or instance and forum permission name" do
            subject.find_permissions(:group).should_not include(tourist_permission, godfather_permission, sneaky_permission, forum_permission)
          end
        end

        context "using a user parameter" do
          it "should get all permissions binded to any resource" do
            subject.find_permissions(:group, admin).should include(group_permission)
          end

          it "should not get permissions not binded to the admin user and forum permission name" do
            subject.find_permissions(:group, admin).should_not include(godfather_permission, tourist_permission, sneaky_permission, forum_permission)
          end
        end

        context "using :any parameter" do
          it "should get all permissions binded to any resource with forum permission name" do
            subject.find_permissions(:group, :any).should include(group_permission)
          end

          it "should not get permissions not binded to a resource with forum permission name" do
            subject.find_permissions(:group, :any).should_not include(godfather_permission, sneaky_permission, forum_permission, tourist_permission)
          end
        end
      end
    end

    context "using :any as permission name parameter" do
      context "on the Forum class" do
        subject { Forum }

        context "without using a user parameter" do
          it "should get all permissions binded to a Forum class or instance" do
            subject.find_permissions(:any).should include(forum_permission, godfather_permission, tourist_permission, sneaky_permission)
          end

          it "should not get permissions not binded to a Forum class or instance" do
            subject.find_permissions(:any).should_not include(group_permission)
          end
        end

        context "using a user parameter" do
          it "should get all permissions binded to a Forum class or instance and admin user" do
            subject.find_permissions(:any, admin).should include(forum_permission, godfather_permission)
          end

          it "should not get permissions not binded to the admin user and Forum class or instance" do
            subject.find_permissions(:any, admin).should_not include(tourist_permission, sneaky_permission, group_permission)
          end
        end

        context "using :any as user parameter" do
          it "should get all permissions binded to a Forum class or instance" do
            subject.find_permissions(:any, :any).should include(forum_permission, godfather_permission, tourist_permission, sneaky_permission)
          end

          it "should not get permissions not binded to a Forum class or instance" do
            subject.find_permissions(:any, :any).should_not include(group_permission)
          end
        end
      end

      context "on the Group class" do
        subject { Group }

        context "without using a user parameter" do
          it "should get all permissions binded to a Group class or instance" do
            subject.find_permissions(:any).should include(group_permission)
          end

          it "should not get permissions not binded to a Group class or instance" do
            subject.find_permissions(:any).should_not include(forum_permission, godfather_permission, tourist_permission, sneaky_permission)
          end
        end

        context "using a user parameter" do
          it "should get all permissions binded to a Group class or instance and admin user" do
            subject.find_permissions(:any, admin).should include(group_permission)
          end

          it "should not get permissions not binded to the admin user and Group class or instance" do
            subject.find_permissions(:any, admin).should_not include(forum_permission, godfather_permission, tourist_permission, sneaky_permission)
          end
        end

        context "using :any as user parameter" do
          it "should get all permissions binded to a Group class or instance" do
            subject.find_permissions(:any, :any).should include(group_permission)
          end

          it "should not get permissions not binded to a Group class or instance" do
            subject.find_permissions(:any, :any).should_not include(forum_permission, godfather_permission, tourist_permission, sneaky_permission)
          end
        end
      end
    end

    context "with a resource using STI" do
      subject{ Organization }
      it "should find instances of children classes" do
        subject.find_permissions(:owner, admin).should =~ [company_permission]
      end
    end
  end

  describe "#permissions" do
    before(:all) { Permission.destroy_all }
    subject { Forum.first }

    it { should respond_to :permissions }

    context "on a Forum instance" do
      its(:permissions) { should match_array( [ forum_permission, sneaky_permission ]) }
      its(:permissions) { should_not include(group_permission, godfather_permission, tourist_permission) }
    end

    context "on a Group instance" do
      subject { Group.last }

      its(:permissions) { should eq([ group_permission ]) }
      its(:permissions) { should_not include(forum_permission, godfather_permission, sneaky_permission, tourist_permission) }

      context "when deleting a Group instance" do
        subject do
          Group.create(:name => "to delete")
        end

        before do
          subject.permissions.create :name => "group_permission1"
          subject.permissions.create :name => "group_permission2"
        end

        it "should remove the permissions binded to this instance" do
          expect { subject.destroy }.to change { Permission.count }.by(-2)
        end
      end
    end
  end

  describe "#applied_permissions" do
    context "on a Forum instance" do
      subject { Forum.first }

      its(:applied_permissions) { should =~ [ forum_permission, godfather_permission, sneaky_permission ] }
      its(:applied_permissions) { should_not include(group_permission, tourist_permission) }
    end

    context "on a Group instance" do
      subject { Group.last }

      its(:applied_permissions) { should =~ [ group_permission ] }
      its(:applied_permissions) { should_not include(forum_permission, godfather_permission, sneaky_permission, tourist_permission) }
    end
  end


  describe '.resource_types' do

    it 'include all models that call resourcify' do
      Rolify.resource_types.should include("HumanResource", "Forum", "Group",
                                          "Team", "Organization")
    end
  end


  describe "#strict" do
    context "strict user" do
      before(:all) do
        @strict_user = StrictUser.first
        @strict_user.permission_ids
        @strict_user.add_permission(:forum, Forum.first)
        @strict_user.add_permission(:forum, Forum)
      end

      it "should return only strict forum" do
        @strict_user.has_permission?(:forum, Forum.first).should be true
        @strict_user.has_cached_permission?(:forum, Forum.first).should be true
      end

      it "should return false on strict another forum" do
        @strict_user.has_permission?(:forum, Forum.last).should be false
        @strict_user.has_cached_permission?(:forum, Forum.last).should be false
      end

      it "should return true if user has permission on Forum model" do
        @strict_user.has_permission?(:forum, Forum).should be true
        @strict_user.has_cached_permission?(:forum, Forum).should be true
      end

      it "should return true if user has permission any forum name" do
        @strict_user.has_permission?(:forum, :any).should be true
        @strict_user.has_cached_permission?(:forum, :any).should be true
      end

      it "should return false when deleted permission on Forum model" do
        @strict_user.remove_permission(:forum, Forum)
        @strict_user.has_permission?(:forum, Forum).should be false
        @strict_user.has_cached_permission?(:forum, Forum).should be false
      end
    end
  end
end
