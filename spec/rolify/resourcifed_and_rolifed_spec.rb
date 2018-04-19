require "spec_helper"

describe "Resourcify and rolify on the same model" do
  
  before(:all) do
    reset_defaults
    Permission.delete_all
    HumanResource.delete_all
  end
  
  let!(:user) do
    user = HumanResource.new login: 'Samer' 
    user.save
    user
  end
  
  it "should add the permission to the user" do
    expect { user.add_permission :admin }.to change { user.permissions.count }.by(1)
  end
      
  it "should create a permission to the permissions collection" do
    expect { user.add_permission :moderator }.to change { Permission.count }.by(1)
  end
end