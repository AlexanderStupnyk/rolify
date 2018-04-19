shared_examples_for "#add_permission_examples" do |param_name, param_method|
  context "using #{param_name} as parameter" do
    context "with a global permission", :scope => :global do
      it "should add the permission to the user" do
        expect { subject.add_permission "root".send(param_method) }.to change { subject.permissions.count }.by(1)
      end

      it "should create a permission to the permissions table" do
        expect { subject.add_permission "moderator".send(param_method) }.to change { permission_class.count }.by(1)
      end

      context "considering a new global permission" do
        it "creates a new class scoped permission" do
          expect(subject.add_permission "expert".send(param_method)).to be_the_same_permission("expert")
        end
      end

      context "should not create another permission" do
        it "if the permission was already assigned to the user" do
          subject.add_permission "manager".send(param_method)
          expect { subject.add_permission "manager".send(param_method) }.not_to change { subject.permissions.size }
        end

        it "if the permission already exists in the db" do
          permission_class.create :name => "god"
          expect { subject.add_permission "god".send(param_method) }.not_to change { permission_class.count }
        end
      end
    end

    context "with a class scoped permission", :scope => :class do
      it "should add the permission to the user" do
        expect { subject.add_permission "supervisor".send(param_method), Forum }.to change { subject.permissions.count }.by(1)
      end

      it "should create a permission in the permissions table" do
        expect { subject.add_permission "moderator".send(param_method), Forum }.to change { permission_class.count }.by(1)
      end

      context "considering a new class scoped permission" do
        it "creates a new class scoped permission" do
          expect(subject.add_permission "boss".send(param_method), Forum).to be_the_same_permission("boss", Forum)
        end
      end

      context "should not create another permission" do
        it "if the permission was already assigned to the user" do
          subject.add_permission "warrior".send(param_method), Forum
          expect { subject.add_permission "warrior".send(param_method), Forum }.not_to change { subject.permissions.count }
        end

        it "if already existing in the database" do
          permission_class.create :name => "hacker", :resource_type => "Forum"
          expect { subject.add_permission "hacker".send(param_method), Forum }.not_to change { permission_class.count }
        end
      end
    end

    context "with an instance scoped permission", :scope => :instance do
      it "should add the permission to the user" do
        expect { subject.add_permission "visitor".send(param_method), Forum.last }.to change { subject.permissions.count }.by(1)
      end

      it "should create a permission in the permissions table" do
        expect { subject.add_permission "member".send(param_method), Forum.last }.to change { permission_class.count }.by(1)
      end

      it "creates a new instance scoped permission" do
        expect(subject.add_permission "mate".send(param_method), Forum.last).to be_the_same_permission("mate", Forum.last)
      end

      context "should not create another permission" do
        it "if the permission was already assigned to the user" do
          subject.add_permission "anonymous".send(param_method), Forum.first
          expect { subject.add_permission "anonymous".send(param_method), Forum.first }.not_to change { subject.permissions.size }
        end

        it "if already existing in the database" do
          permission_class.create :name => "ghost", :resource_type => "Forum", :resource_id => Forum.first.id
          expect { subject.add_permission "ghost".send(param_method), Forum.first }.not_to change { permission_class.count }
        end
      end
    end
  end
end