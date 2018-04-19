shared_examples_for "Rolify.callbacks" do
  before(:all) do
    reset_defaults
    Rolify.dynamic_shortcuts = false
    permission_class.destroy_all
  end

  after :each do
    @user.permissions.destroy_all
  end

  describe "rolify association callbacks", :if => (Rolify.orm == "active_record") do
    describe "before_add" do
      it "should receive callback" do
        rolify_options = { :permission_cname => permission_class.to_s, :before_add => :permission_callback }
        rolify_options[:permission_join_table_name] = join_table if defined? join_table
        silence_warnings { user_class.rolify rolify_options }
        @user = user_class.first
        @user.stub(:permission_callback)
        @user.should_receive(:permission_callback)
        @user.add_permission :admin
      end
    end

    describe "after_add" do
      it "should receive callback" do
        rolify_options = { :permission_cname => permission_class.to_s, :after_add => :permission_callback }
        rolify_options[:permission_join_table_name] = join_table if defined? join_table
        silence_warnings { user_class.rolify rolify_options }
        @user = user_class.first
        @user.stub(:permission_callback)
        @user.should_receive(:permission_callback)
        @user.add_permission :admin
      end
    end

    describe "before_remove" do
      it "should receive callback" do
        rolify_options = { :permission_cname => permission_class.to_s, :before_remove => :permission_callback }
        rolify_options[:permission_join_table_name] = join_table if defined? join_table
        silence_warnings { user_class.rolify rolify_options }
        @user = user_class.first
        @user.add_permission :admin
        @user.stub(:permission_callback)

        @user.should_receive(:permission_callback)
        @user.remove_permission :admin
      end
    end

    describe "after_remove" do
      it "should receive callback" do
        rolify_options = { :permission_cname => permission_class.to_s, :after_remove => :permission_callback }
        rolify_options[:permission_join_table_name] = join_table if defined? join_table
        silence_warnings { user_class.rolify rolify_options }
        @user = user_class.first
        @user.add_permission :admin
        @user.stub(:permission_callback)

        @user.should_receive(:permission_callback)
        @user.remove_permission :admin
      end
    end
  end
end
