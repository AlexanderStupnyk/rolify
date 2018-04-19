shared_context "global permission", :scope => :global do
  subject { admin }
  
  def admin
    user_class.first
  end
  
  before(:all) do
    load_permissions
    create_other_permissions
  end
  
  def load_permissions
    permission_class.destroy_all
    admin.permissions = []
    admin.add_permission :admin
    admin.add_permission :staff
    admin.add_permission :manager, Group
    admin.add_permission :player, Forum
    admin.add_permission :moderator, Forum.last
    admin.add_permission :moderator, Group.last
    admin.add_permission :anonymous, Forum.first
  end
end

shared_context "class scoped permission", :scope => :class do
  subject { manager }
  
  before(:all) do
    load_permissions
    create_other_permissions
  end
  
  def manager
    user_class.where(:login => "moderator").first
  end
  
  def load_permissions
    permission_class.destroy_all
    manager.permissions = []
    manager.add_permission :manager, Forum
    manager.add_permission :player, Forum 
    manager.add_permission :warrior
    manager.add_permission :moderator, Forum.last
    manager.add_permission :moderator, Group.last
    manager.add_permission :anonymous, Forum.first
  end
end

shared_context "instance scoped permission", :scope => :instance do
  subject { moderator }
  
  before(:all) do
    load_permissions
    create_other_permissions
  end
  
  def moderator
    user_class.where(:login => "god").first
  end
  
  def load_permissions
    permission_class.destroy_all
    moderator.permissions = []
    moderator.add_permission :moderator, Forum.first
    moderator.add_permission :anonymous, Forum.last
    moderator.add_permission :visitor, Forum
    moderator.add_permission :soldier
  end
end

shared_context "mixed scoped permissions", :scope => :mixed do
  subject { user_class }
  
  before(:all) do
    permission_class.destroy_all
  end
    
  let!(:root) { provision_user(user_class.first, [ :admin, :staff, [ :moderator, Group ], [ :visitor, Forum.last ] ]) }
  let!(:modo) { provision_user(user_class.where(:login => "moderator").first, [[ :moderator, Forum ], [ :manager, Group ], [ :visitor, Group.first ]])}
  let!(:visitor) { provision_user(user_class.last, [[ :visitor, Forum.last ]]) }
  let!(:owner) { provision_user(user_class.first, [[:owner, Company.first]]) }
end

def create_other_permissions
  permission_class.create :name => "superhero"
  permission_class.create :name => "admin", :resource_type => "Group"
  permission_class.create :name => "admin", :resource => Forum.first
  permission_class.create :name => "VIP", :resource_type => "Forum"
  permission_class.create :name => "manager", :resource => Forum.last
  permission_class.create :name => "roomate", :resource => Forum.first
  permission_class.create :name => "moderator", :resource => Group.first
end