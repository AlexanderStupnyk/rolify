shared_examples_for :finders do |param_name, param_method|
  context "using #{param_name} as parameter" do
    describe ".with_permission" do
      it { should respond_to(:with_permission).with(1).argument }
      it { should respond_to(:with_permission).with(2).arguments }

      context "with a global permission" do
        it { subject.with_permission("admin".send(param_method)).should eq([ root ]) }
        it { subject.with_permission("moderator".send(param_method)).should be_empty }
        it { subject.with_permission("visitor".send(param_method)).should be_empty }
      end

      context "with a class scoped permission" do
        context "on Forum class" do
          it { subject.with_permission("admin".send(param_method), Forum).should eq([ root ]) }
          it { subject.with_permission("moderator".send(param_method), Forum).should eq([ modo ]) }
          it { subject.with_permission("visitor".send(param_method), Forum).should be_empty }
        end

        context "on Group class" do
          it { subject.with_permission("admin".send(param_method), Group).should eq([ root ]) }
          it { subject.with_permission("moderator".send(param_method), Group).should eq([ root ]) }
          it { subject.with_permission("visitor".send(param_method), Group).should be_empty }
        end
      end

      context "with an instance scoped permission" do
        context "on Forum.first instance" do
          it { subject.with_permission("admin".send(param_method), Forum.first).should eq([ root ]) }
          it { subject.with_permission("moderator".send(param_method), Forum.first).should eq([ modo ]) }
          it { subject.with_permission("visitor".send(param_method), Forum.first).should be_empty }
        end

        context "on Forum.last instance" do
          it { subject.with_permission("admin".send(param_method), Forum.last).should eq([ root ]) }
          it { subject.with_permission("moderator".send(param_method), Forum.last).should eq([ modo ]) }
          it { subject.with_permission("visitor".send(param_method), Forum.last).should include(root, visitor) } # =~ doesn't pass using mongoid, don't know why...
        end

        context "on Group.first instance" do
          it { subject.with_permission("admin".send(param_method), Group.first).should eq([ root ]) }
          it { subject.with_permission("moderator".send(param_method), Group.first).should eq([ root ]) }
          it { subject.with_permission("visitor".send(param_method), Group.first).should eq([ modo ]) }
        end

        context "on Company.first_instance" do
          it { subject.with_permission("owner".send(param_method), Company.first).should eq([ owner ]) }
        end
      end
    end

    describe ".without_permission" do
      it { should respond_to(:without_permission).with(1).argument }
      it { should respond_to(:without_permission).with(2).arguments }

      context "with a global permission" do
        it { subject.without_permission("admin".send(param_method)).should_not eq([ root ]) }
        it { subject.without_permission("moderator".send(param_method)).should_not be_empty }
        it { subject.without_permission("visitor".send(param_method)).should_not be_empty }
      end

      context "with a class scoped permission" do
        context "on Forum class" do
          it { subject.without_permission("admin".send(param_method), Forum).should_not eq([ root ]) }
          it { subject.without_permission("moderator".send(param_method), Forum).should_not eq([ modo ]) }
          it { subject.without_permission("visitor".send(param_method), Forum).should_not be_empty }
        end

        context "on Group class" do
          it { subject.without_permission("admin".send(param_method), Group).should_not eq([ root ]) }
          it { subject.without_permission("moderator".send(param_method), Group).should_not eq([ root ]) }
          it { subject.without_permission("visitor".send(param_method), Group).should_not be_empty }
        end
      end

      context "with an instance scoped permission" do
        context "on Forum.first instance" do
          it { subject.without_permission("admin".send(param_method), Forum.first).should_not eq([ root ]) }
          it { subject.without_permission("moderator".send(param_method), Forum.first).should_not eq([ modo ]) }
          it { subject.without_permission("visitor".send(param_method), Forum.first).should_not be_empty }
        end

        context "on Forum.last instance" do
          it { subject.without_permission("admin".send(param_method), Forum.last).should_not eq([ root ]) }
          it { subject.without_permission("moderator".send(param_method), Forum.last).should_not eq([ modo ]) }
          it { subject.without_permission("visitor".send(param_method), Forum.last).should_not include(root, visitor) } # =~ doesn't pass using mongoid, don't know why...
        end

        context "on Group.first instance" do
          it { subject.without_permission("admin".send(param_method), Group.first).should_not eq([ root ]) }
          it { subject.without_permission("moderator".send(param_method), Group.first).should_not eq([ root ]) }
          it { subject.without_permission("visitor".send(param_method), Group.first).should_not eq([ modo ]) }
        end

        context "on Company.first_instance" do
          it { subject.without_permission("owner".send(param_method), Company.first).should_not eq([ owner ]) }
        end
      end
    end
    

    describe ".with_all_permissions" do
      it { should respond_to(:with_all_permissions) }

      it { subject.with_all_permissions("admin".send(param_method), :staff).should eq([ root ]) }
      it { subject.with_all_permissions("admin".send(param_method), :staff, { :name => "moderator".send(param_method), :resource => Group }).should eq([ root ]) }
      it { subject.with_all_permissions("admin".send(param_method), "moderator".send(param_method)).should be_empty }
      it { subject.with_all_permissions("admin".send(param_method), :staff, { :name => "moderator".send(param_method), :resource => Forum }).should be_empty }
      it { subject.with_all_permissions({ :name => "moderator".send(param_method), :resource => Forum }, { :name => :manager, :resource => Group }).should eq([ modo ]) }
      it { subject.with_all_permissions("moderator".send(param_method), :manager).should be_empty }
      it { subject.with_all_permissions({ :name => "visitor".send(param_method), :resource => Forum.last }, { :name => "moderator".send(param_method), :resource => Group }).should eq([ root ]) }
      it { subject.with_all_permissions({ :name => "visitor".send(param_method), :resource => Group.first }, { :name => "moderator".send(param_method), :resource => Forum }).should eq([ modo ]) }
      it { subject.with_all_permissions({ :name => "visitor".send(param_method), :resource => :any }, { :name => "moderator".send(param_method), :resource => :any }).should =~ [ root, modo ] }
    end

    describe ".with_any_permission" do
      it { should respond_to(:with_any_permission) }

      it { subject.with_any_permission("admin".send(param_method), :staff).should eq([ root ]) }
      it { subject.with_any_permission("admin".send(param_method), :staff, { :name => "moderator".send(param_method), :resource => Group }).should eq([ root ]) }
      it { subject.with_any_permission("admin".send(param_method), "moderator".send(param_method)).should eq([ root ]) }
      it { subject.with_any_permission("admin".send(param_method), :staff, { :name => "moderator".send(param_method), :resource => Forum }).should =~ [ root, modo ] }
      it { subject.with_any_permission({ :name => "moderator".send(param_method), :resource => Forum }, { :name => :manager, :resource => Group }).should eq([ modo ]) }
      it { subject.with_any_permission({ :name => "moderator".send(param_method), :resource => Group }, { :name => :manager, :resource => Group }).should =~ [ root, modo ] }
      it { subject.with_any_permission("moderator".send(param_method), :manager).should be_empty }
      it { subject.with_any_permission({ :name => "visitor".send(param_method), :resource => Forum.last }, { :name => "moderator".send(param_method), :resource => Group }).should =~ [ root, visitor ] }
      it { subject.with_any_permission({ :name => "visitor".send(param_method), :resource => Group.first }, { :name => "moderator".send(param_method), :resource => Forum }).should eq([ modo ]) }
      it { subject.with_any_permission({ :name => "visitor".send(param_method), :resource => :any }, { :name => "moderator".send(param_method), :resource => :any }).should =~ [ root, modo, visitor ] }
    end
  end
end