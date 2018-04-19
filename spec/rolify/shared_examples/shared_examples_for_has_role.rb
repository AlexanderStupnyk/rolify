shared_examples_for "#has_permission?_examples" do |param_name, param_method|
  context "using #{param_name} as parameter" do
    context "with a global permission", :scope => :global do
      it { subject.has_permission?("admin".send(param_method)).should be_truthy }

      it { subject.has_cached_permission?("admin".send(param_method)).should be_truthy }

      context "on resource request" do
        it { subject.has_permission?("admin".send(param_method), Forum.first).should be_truthy }
        it { subject.has_permission?("admin".send(param_method), Forum).should be_truthy }
        it { subject.has_permission?("admin".send(param_method), :any).should be_truthy }

        it { subject.has_cached_permission?("admin".send(param_method), Forum.first).should be_truthy }
        it { subject.has_cached_permission?("admin".send(param_method), Forum).should be_truthy }
        it { subject.has_cached_permission?("admin".send(param_method), :any).should be_truthy }
      end

      context "with another global permission" do
        before(:all) { permission_class.create(:name => "global") }

        it { subject.has_permission?("global".send(param_method)).should be_falsey }
        it { subject.has_permission?("global".send(param_method), :any).should be_falsey }

        it { subject.has_cached_permission?("global".send(param_method)).should be_falsey }
        it { subject.has_cached_permission?("global".send(param_method), :any).should be_falsey }
      end

      it "should not get an instance scoped permission" do
        subject.has_permission?("moderator".send(param_method), Group.first).should be_falsey

        subject.has_cached_permission?("moderator".send(param_method), Group.first).should be_falsey
      end

      it "should not get a class scoped permission" do
        subject.has_permission?("manager".send(param_method), Forum).should be_falsey

        subject.has_cached_permission?("manager".send(param_method), Forum).should be_falsey
      end

      context "using inexisting permission" do
        it { subject.has_permission?("dummy".send(param_method)).should be_falsey }
        it { subject.has_permission?("dumber".send(param_method), Forum.first).should be_falsey }

        it { subject.has_cached_permission?("dummy".send(param_method)).should be_falsey }
        it { subject.has_cached_permission?("dumber".send(param_method), Forum.first).should be_falsey }
      end
    end

    context "with a class scoped permission", :scope => :class do
      context "on class scoped permission request" do
        it { subject.has_permission?("manager".send(param_method), Forum).should be_truthy }
        it { subject.has_permission?("manager".send(param_method), Forum.first).should be_truthy }
        it { subject.has_permission?("manager".send(param_method), :any).should be_truthy }

        it { subject.has_cached_permission?("manager".send(param_method), Forum).should be_truthy }
        it { subject.has_cached_permission?("manager".send(param_method), Forum.first).should be_truthy }
        it { subject.has_cached_permission?("manager".send(param_method), :any).should be_truthy }
      end

      it "should not get a scoped permission when asking for a global" do
        subject.has_permission?("manager".send(param_method)).should be_falsey

        subject.has_cached_permission?("manager".send(param_method)).should be_falsey
      end

      it "should not get a global permission" do
        permission_class.create(:name => "admin")
        subject.has_permission?("admin".send(param_method)).should be_falsey

        subject.has_cached_permission?("admin".send(param_method)).should be_falsey
      end

      context "with another class scoped permission" do
        context "on the same resource but with a different name" do
          before(:all) { permission_class.create(:name => "member", :resource_type => "Forum") }

          it { subject.has_permission?("member".send(param_method), Forum).should be_falsey }
          it { subject.has_permission?("member".send(param_method), :any).should be_falsey }

          it { subject.has_cached_permission?("member".send(param_method), Forum).should be_falsey }
          it { subject.has_cached_permission?("member".send(param_method), :any).should be_falsey }
        end

        context "on another resource with the same name" do
          before(:all) { permission_class.create(:name => "manager", :resource_type => "Group") }

          it { subject.has_permission?("manager".send(param_method), Group).should be_falsey }
          it { subject.has_permission?("manager".send(param_method), :any).should be_truthy }

          it { subject.has_cached_permission?("manager".send(param_method), Group).should be_falsey }
          it { subject.has_cached_permission?("manager".send(param_method), :any).should be_truthy }
        end

        context "on another resource with another name" do
          before(:all) { permission_class.create(:name => "defenders", :resource_type => "Group") }

          it { subject.has_permission?("defenders".send(param_method), Group).should be_falsey }
          it { subject.has_permission?("defenders".send(param_method), :any).should be_falsey }

          it { subject.has_cached_permission?("defenders".send(param_method), Group).should be_falsey }
          it { subject.has_cached_permission?("defenders".send(param_method), :any).should be_falsey }
        end
      end

      context "using inexisting permission" do
        it { subject.has_permission?("dummy".send(param_method), Forum).should be_falsey }
        it { subject.has_permission?("dumber".send(param_method)).should be_falsey }

        it { subject.has_cached_permission?("dummy".send(param_method), Forum).should be_falsey }
        it { subject.has_cached_permission?("dumber".send(param_method)).should be_falsey }
      end
    end

    context "with a instance scoped permission", :scope => :instance do
      context "on instance scoped permission request" do
        it { subject.has_permission?("moderator".send(param_method), Forum.first).should be_truthy }
        it { subject.has_permission?("moderator".send(param_method), :any).should be_truthy }
        it {
          m = subject.class.new
          m.add_permission("moderator", Forum.first)
          m.has_permission?("moderator".send(param_method), :any).should be_truthy
        }

        it { subject.has_cached_permission?("moderator".send(param_method), Forum.first).should be_truthy }
        it { subject.has_cached_permission?("moderator".send(param_method), :any).should be_truthy }
        it {
          m = subject.class.new
          m.add_permission("moderator", Forum.first)
          m.has_cached_permission?("moderator".send(param_method), :any).should be_truthy
        }
      end

      it "should not get an instance scoped permission when asking for a global" do
        subject.has_permission?("moderator".send(param_method)).should be_falsey

        subject.has_cached_permission?("moderator".send(param_method)).should be_falsey
      end

      it "should not get an instance scoped permission when asking for a class scoped" do 
        subject.has_permission?("moderator".send(param_method), Forum).should be_falsey

        subject.has_cached_permission?("moderator".send(param_method), Forum).should be_falsey
      end

      it "should not get a global permission" do
        permission_class.create(:name => "admin")
        subject.has_permission?("admin".send(param_method)).should be_falsey

        subject.has_cached_permission?("admin".send(param_method)).should be_falsey
      end

      context "with another instance scoped permission" do
        context "on the same resource but with a different permission name" do
          before(:all) { permission_class.create(:name => "member", :resource => Forum.first) }

          it { subject.has_permission?("member".send(param_method), Forum.first).should be_falsey }
          it { subject.has_permission?("member".send(param_method), :any).should be_falsey }

          it { subject.has_cached_permission?("member".send(param_method), Forum.first).should be_falsey }
          it { subject.has_cached_permission?("member".send(param_method), :any).should be_falsey }
        end

        context "on another resource of the same type but with the same permission name" do
          before(:all) { permission_class.create(:name => "moderator", :resource => Forum.last) }

          it { subject.has_permission?("moderator".send(param_method), Forum.last).should be_falsey }
          it { subject.has_permission?("moderator".send(param_method), :any).should be_truthy }

          it { subject.has_cached_permission?("moderator".send(param_method), Forum.last).should be_falsey }
          it { subject.has_cached_permission?("moderator".send(param_method), :any).should be_truthy }
        end

        context "on another resource of different type but with the same permission name" do
          before(:all) { permission_class.create(:name => "moderator", :resource => Group.last) }

          it { subject.has_permission?("moderator".send(param_method), Group.last).should be_falsey }
          it { subject.has_permission?("moderator".send(param_method), :any).should be_truthy }

          it { subject.has_cached_permission?("moderator".send(param_method), Group.last).should be_falsey }
          it { subject.has_cached_permission?("moderator".send(param_method), :any).should be_truthy }
        end

        context "on another resource of the same type and with another permission name" do
          before(:all) { permission_class.create(:name => "member", :resource => Forum.last) }

          it { subject.has_permission?("member".send(param_method), Forum.last).should be_falsey }
          it { subject.has_permission?("member".send(param_method), :any).should be_falsey }

          it { subject.has_cached_permission?("member".send(param_method), Forum.last).should be_falsey }
          it { subject.has_cached_permission?("member".send(param_method), :any).should be_falsey }
        end

        context "on another resource of different type and with another permission name" do
          before(:all) { permission_class.create(:name => "member", :resource => Group.first) }

          it { subject.has_permission?("member".send(param_method), Group.first).should be_falsey }
          it { subject.has_permission?("member".send(param_method), :any).should be_falsey }

          it { subject.has_cached_permission?("member".send(param_method), Group.first).should be_falsey }
          it { subject.has_cached_permission?("member".send(param_method), :any).should be_falsey }
        end
      end
    end
  end
end
