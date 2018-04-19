shared_examples_for "#remove_permission_examples" do |param_name, param_method|
  context "using #{param_name} as parameter" do
    context "removing a global permission", :scope => :global do
      context "being a global permission of the user" do
        it { expect { subject.remove_permission("admin".send(param_method)) }.to change { subject.permissions.size }.by(-1) }

        it { should_not have_permission("admin".send(param_method)) }
      end

      context "being a class scoped permission to the user" do
        it { expect { subject.remove_permission("manager".send(param_method)) }.to change { subject.permissions.size }.by(-1) }

        it { should_not have_permission("manager".send(param_method), Group) }
      end

      context "being instance scoped permissions to the user" do
        it { expect { subject.remove_permission("moderator".send(param_method)) }.to change { subject.permissions.size }.by(-2) }

        it { should_not have_permission("moderator".send(param_method), Forum.last) }
        it { should_not have_permission("moderator".send(param_method), Group.last) }
      end

      context "not being a permission of the user" do
        it { expect { subject.remove_permission("superhero".send(param_method)) }.not_to change { subject.permissions.size } }
      end

      context "used by another user" do
        before do
          user = user_class.last
          user.add_permission "staff".send(param_method)
        end

        it { expect { subject.remove_permission("staff".send(param_method)) }.not_to change { permission_class.count } }

        it { should_not have_permission("staff".send(param_method)) }
      end

      context "not used by anyone else" do
        before do
          subject.add_permission "nobody".send(param_method)
        end

        it { expect { subject.remove_permission("nobody".send(param_method)) }.to change { permission_class.count }.by(-1) }
      end
    end

    context "removing a class scoped permission", :scope => :class do
      context "being a global permission of the user" do
        it { expect { subject.remove_permission("warrior".send(param_method), Forum) }.not_to change{ subject.permissions.size } }
      end

      context "being a class scoped permission to the user" do
        it { expect { subject.remove_permission("manager".send(param_method), Forum) }.to change{ subject.permissions.size }.by(-1) }

        it { should_not have_permission("manager", Forum) }
      end

      context "being instance scoped permission to the user" do
        it { expect { subject.remove_permission("moderator".send(param_method), Forum) }.to change { subject.permissions.size }.by(-1) }

        it { should_not have_permission("moderator".send(param_method), Forum.last) }
        it { should     have_permission("moderator".send(param_method), Group.last) }
      end

      context "not being a permission of the user" do
        it { expect { subject.remove_permission("manager".send(param_method), Group) }.not_to change { subject.permissions.size } }
      end
    end

    context "removing a instance scoped permission", :scope => :instance do
      context "being a global permission of the user" do
        it { expect { subject.remove_permission("soldier".send(param_method), Group.first) }.not_to change { subject.permissions.size } }
      end

      context "being a class scoped permission to the user" do
        it { expect { subject.remove_permission("visitor".send(param_method), Forum.first) }.not_to change { subject.permissions.size } }
      end

      context "being instance scoped permission to the user" do
        it { expect { subject.remove_permission("moderator".send(param_method), Forum.first) }.to change { subject.permissions.size }.by(-1) }

        it { should_not have_permission("moderator", Forum.first) }
      end

      context "not being a permission of the user" do
        it { expect { subject.remove_permission("anonymous".send(param_method), Forum.first) }.not_to change { subject.permissions.size } }
      end
    end
  end
end
