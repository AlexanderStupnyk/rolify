shared_examples_for "#only_has_permission?_examples" do |param_name, param_method|
  context "using #{param_name} as parameter" do
    context "with a global permission", :scope => :global do
      subject do 
        user = User.create(:login => "global_user")
        user.add_permission "global_permission".send(param_method)
        user
      end
      
      it { subject.only_has_permission?("global_permission".send(param_method)).should be_truthy }

      context "on resource request" do
        it { subject.only_has_permission?("global_permission".send(param_method), Forum.first).should be_truthy }
        it { subject.only_has_permission?("global_permission".send(param_method), Forum).should be_truthy }
        it { subject.only_has_permission?("global_permission".send(param_method), :any).should be_truthy }
      end

      context "with another global permission" do
        before(:all) { permission_class.create(:name => "another_global_permission") }

        it { subject.only_has_permission?("another_global_permission".send(param_method)).should be_falsey }
        it { subject.only_has_permission?("another_global_permission".send(param_method), :any).should be_falsey }
      end

      it "should not get an instance scoped permission" do
        subject.only_has_permission?("moderator".send(param_method), Group.first).should be_falsey
      end

      it "should not get a class scoped permission" do
        subject.only_has_permission?("manager".send(param_method), Forum).should be_falsey
      end

      context "using inexisting permission" do
        it { subject.only_has_permission?("dummy".send(param_method)).should be_falsey }
        it { subject.only_has_permission?("dumber".send(param_method), Forum.first).should be_falsey }
      end
      
      context "with multiple permissions" do
        before { subject.add_permission "multiple_global_permissions".send(param_method) }
        
        it { subject.only_has_permission?("global_permission".send(param_method)).should be_falsey }
      end
    end

    context "with a class scoped permission", :scope => :class do
      subject do 
        user = User.create(:login => "class_user")
        user.add_permission "class_permission".send(param_method), Forum
        user
      end
      
      context "on class scoped permission request" do
        it { subject.only_has_permission?("class_permission".send(param_method), Forum).should be_truthy }
        it { subject.only_has_permission?("class_permission".send(param_method), Forum.first).should be_truthy }
        it { subject.only_has_permission?("class_permission".send(param_method), :any).should be_truthy }
      end

      it "should not get a scoped permission when asking for a global" do
        subject.only_has_permission?("class_permission".send(param_method)).should be_falsey
      end

      it "should not get a global permission" do
        permission_class.create(:name => "global_permission")
        subject.only_has_permission?("global_permission".send(param_method)).should be_falsey
      end

      context "with another class scoped permission" do
        context "on the same resource but with a different name" do
          before(:all) { permission_class.create(:name => "another_class_permission", :resource_type => "Forum") }

          it { subject.only_has_permission?("another_class_permission".send(param_method), Forum).should be_falsey }
          it { subject.only_has_permission?("another_class_permission".send(param_method), :any).should be_falsey }
        end

        context "on another resource with the same name" do
          before(:all) { permission_class.create(:name => "class_permission", :resource_type => "Group") }

          it { subject.only_has_permission?("class_permission".send(param_method), Group).should be_falsey }
          it { subject.only_has_permission?("class_permission".send(param_method), :any).should be_truthy }
        end

        context "on another resource with another name" do
          before(:all) { permission_class.create(:name => "another_class_permission", :resource_type => "Group") }

          it { subject.only_has_permission?("another_class_permission".send(param_method), Group).should be_falsey }
          it { subject.only_has_permission?("another_class_permission".send(param_method), :any).should be_falsey }
        end
      end

      context "using inexisting permission" do
        it { subject.only_has_permission?("dummy".send(param_method), Forum).should be_falsey }
        it { subject.only_has_permission?("dumber".send(param_method)).should be_falsey }
      end
      
      context "with multiple permissions" do
        before { subject.add_permission "multiple_class_permissions".send(param_method) }
        
        it { subject.only_has_permission?("class_permission".send(param_method), Forum).should be_falsey }
        it { subject.only_has_permission?("class_permission".send(param_method), Forum.first).should be_falsey }
        it { subject.only_has_permission?("class_permission".send(param_method), :any).should be_falsey }
      end
    end

    context "with a instance scoped permission", :scope => :instance do
      subject do 
        user = User.create(:login => "instance_user")
        user.add_permission "instance_permission".send(param_method), Forum.first
        user
      end
      
      context "on instance scoped permission request" do
        it { subject.only_has_permission?("instance_permission".send(param_method), Forum.first).should be_truthy }
        it { subject.only_has_permission?("instance_permission".send(param_method), :any).should be_truthy }
      end

      it "should not get an instance scoped permission when asking for a global" do
        subject.only_has_permission?("instance_permission".send(param_method)).should be_falsey
      end

      it "should not get an instance scoped permission when asking for a class scoped" do
        subject.only_has_permission?("instance_permission".send(param_method), Forum).should be_falsey
      end

      it "should not get a global permission" do
        permission_class.create(:name => "global_permission")
        subject.only_has_permission?("global_permission".send(param_method)).should be_falsey
      end

      context "with another instance scoped permission" do
        context "on the same resource but with a different permission name" do
          before(:all) { permission_class.create(:name => "another_instance_permission", :resource => Forum.first) }

          it { subject.only_has_permission?("another_instance_permission".send(param_method), Forum.first).should be_falsey }
          it { subject.only_has_permission?("another_instance_permission".send(param_method), :any).should be_falsey }
        end

        context "on another resource of the same type but with the same permission name" do
          before(:all) { permission_class.create(:name => "moderator", :resource => Forum.last) }

          it { subject.only_has_permission?("instance_permission".send(param_method), Forum.last).should be_falsey }
          it { subject.only_has_permission?("instance_permission".send(param_method), :any).should be_truthy }
        end

        context "on another resource of different type but with the same permission name" do
          before(:all) { permission_class.create(:name => "moderator", :resource => Group.last) }

          it { subject.only_has_permission?("instance_permission".send(param_method), Group.last).should be_falsey }
          it { subject.only_has_permission?("instance_permission".send(param_method), :any).should be_truthy }
        end

        context "on another resource of the same type and with another permission name" do
          before(:all) { permission_class.create(:name => "another_instance_permission", :resource => Forum.last) }

          it { subject.only_has_permission?("another_instance_permission".send(param_method), Forum.last).should be_falsey }
          it { subject.only_has_permission?("another_instance_permission".send(param_method), :any).should be_falsey }
        end

        context "on another resource of different type and with another permission name" do
          before(:all) { permission_class.create(:name => "another_instance_permission", :resource => Group.first) }

          it { subject.only_has_permission?("another_instance_permission".send(param_method), Group.first).should be_falsey }
          it { subject.only_has_permission?("another_instance_permission".send(param_method), :any).should be_falsey }
        end
      end
    
      context "with multiple permissions" do
        before { subject.add_permission "multiple_instance_permissions".send(param_method), Forum.first }
        
        it { subject.only_has_permission?("instance_permission".send(param_method), Forum.first).should be_falsey }
        it { subject.only_has_permission?("instance_permission".send(param_method), :any).should be_falsey }
      end
    end
  end
end