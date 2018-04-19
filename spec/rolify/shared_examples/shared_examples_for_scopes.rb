require "rolify/shared_contexts"

shared_examples_for "Permission.scopes" do
  before do
    permission_class.destroy_all
  end
  
  subject { user_class.first }
  
  describe ".global" do 
    let!(:admin_permission) { subject.add_permission :admin }
    let!(:staff_permission) { subject.add_permission :staff }
     
    it { subject.permissions.global.should == [ admin_permission, staff_permission ] }
  end
  
  describe ".class_scoped" do
    let!(:manager_permission) { subject.add_permission :manager, Group }
    let!(:moderator_permission) { subject.add_permission :moderator, Forum }
    
    it { subject.permissions.class_scoped.should =~ [ manager_permission, moderator_permission ] }
    it { subject.permissions.class_scoped(Group).should =~ [ manager_permission ] }
    it { subject.permissions.class_scoped(Forum).should =~ [ moderator_permission ] }
  end
  
  describe ".instance_scoped" do
    let!(:visitor_permission) { subject.add_permission :visitor, Forum.first }
    let!(:zombie_permission) { subject.add_permission :visitor, Forum.last }
    let!(:anonymous_permission) { subject.add_permission :anonymous, Group.last }
    
    it { subject.permissions.instance_scoped.to_a.entries.should =~ [ visitor_permission, zombie_permission, anonymous_permission ] }
    it { subject.permissions.instance_scoped(Forum).should =~ [ visitor_permission, zombie_permission ] }
    it { subject.permissions.instance_scoped(Forum.first).should =~ [ visitor_permission ] }
    it { subject.permissions.instance_scoped(Forum.last).should =~ [ zombie_permission ] }
    it { subject.permissions.instance_scoped(Group.last).should =~ [ anonymous_permission ] }
    it { subject.permissions.instance_scoped(Group.first).should be_empty }
  end
end