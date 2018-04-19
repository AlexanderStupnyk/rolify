require "spec_helper"
require "rolify/shared_examples/shared_examples_for_permissions"
require "rolify/shared_examples/shared_examples_for_dynamic"
require "rolify/shared_examples/shared_examples_for_scopes"
require "rolify/shared_examples/shared_examples_for_callbacks"

describe "Using Rolify with custom User and Permission class names" do
  def user_class
    Customer
  end

  def permission_class
    Privilege
  end
  
  it_behaves_like Rolify::Permission
  it_behaves_like "Permission.scopes"
  it_behaves_like Rolify::Dynamic
  it_behaves_like "Rolify.callbacks"
end
