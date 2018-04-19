shared_examples_for "#has_any_permission?_examples" do |param_name, param_method|
  context "using #{param_name} as parameter" do
    context "with a global permission", :scope => :global do
      before do
        subject.add_permission "staff".send(param_method)
      end
      
      it { subject.has_any_permission?("staff".send(param_method)).should be_truthy }
      it { subject.has_any_permission?("admin".send(param_method), "staff".send(param_method)).should be_truthy }
      it { subject.has_any_permission?("admin".send(param_method), "moderator".send(param_method)).should be_truthy }
      it { subject.has_any_permission?("dummy".send(param_method), "dumber".send(param_method)).should be_falsey }
      it { subject.has_any_permission?({ :name => "admin".send(param_method), :resource => Forum }, { :name => "admin".send(param_method), :resource => Group }).should be_truthy }
      it { subject.has_any_permission?({ :name => "admin".send(param_method), :resource => :any }, { :name => "admin".send(param_method), :resource => Group }).should be_truthy }
      it { subject.has_any_permission?({ :name => "admin".send(param_method), :resource => Forum }, { :name => "staff".send(param_method), :resource => Group.last }).should be_truthy }
      it { subject.has_any_permission?({ :name => "admin".send(param_method), :resource => Forum.first }, { :name => "admin".send(param_method), :resource => Forum.last }).should be_truthy }
      it { subject.has_any_permission?({ :name => "admin".send(param_method), :resource => Forum.first }, { :name => "dummy".send(param_method), :resource => Forum.last }).should be_truthy }
      it { subject.has_any_permission?({ :name => "admin".send(param_method), :resource => Forum.first }, { :name => "dummy".send(param_method), :resource => :any }).should be_truthy }
      it { subject.has_any_permission?({ :name => "dummy".send(param_method), :resource => Forum.first }, { :name => "dumber".send(param_method), :resource => :any }).should be_falsey }
      it { subject.has_any_permission?({ :name => "dummy".send(param_method), :resource => :any }, { :name => "dumber".send(param_method), :resource => :any }).should be_falsey }
    end
    
    context "with a class scoped permission", :scope => :class do
      before do
        subject.add_permission "player".send(param_method), Forum
        subject.add_permission "superhero".send(param_method)
      end
      
      it { subject.has_any_permission?({ :name => "player".send(param_method), :resource => Forum }).should be_truthy }
      it { subject.has_any_permission?({ :name => "manager".send(param_method), :resource => Forum }, { :name => "player".send(param_method), :resource => Forum }).should be_truthy }
      it { subject.has_any_permission?({ :name => "manager".send(param_method), :resource => Forum }, { :name => "player".send(param_method), :resource => :any }).should be_truthy }
      it { subject.has_any_permission?({ :name => "manager".send(param_method), :resource => Forum }, { :name => "player".send(param_method), :resource => :any }).should be_truthy }
      it { subject.has_any_permission?({ :name => "manager".send(param_method), :resource => :any }, { :name => "player".send(param_method), :resource => :any }).should be_truthy }
      it { subject.has_any_permission?({ :name => "manager".send(param_method), :resource => Forum }, { :name => "dummy".send(param_method), :resource => Forum }).should be_truthy }
      it { subject.has_any_permission?({ :name => "manager".send(param_method), :resource => Forum }, { :name => "dummy".send(param_method), :resource => :any }).should be_truthy }
      it { subject.has_any_permission?({ :name => "dummy".send(param_method), :resource => Forum }, { :name => "dumber".send(param_method), :resource => Group }).should be_falsey }
      it { subject.has_any_permission?({ :name => "manager".send(param_method), :resource => Forum.first }, { :name => "manager".send(param_method), :resource => Forum.last }).should be_truthy }
      it { subject.has_any_permission?({ :name => "manager".send(param_method), :resource => Group }, { :name => "moderator".send(param_method), :resource => Forum.first }).should be_falsey }
      it { subject.has_any_permission?({ :name => "manager".send(param_method), :resource => Forum.first }, { :name => "moderator".send(param_method), :resource => Forum }).should be_truthy }
      it { subject.has_any_permission?({ :name => "manager".send(param_method), :resource => Forum.last }, { :name => "warrior".send(param_method), :resource => Forum.last }).should be_truthy }
    end
    
    context "with a instance scoped permission", :scope => :instance do
      before do
        subject.add_permission "visitor".send(param_method), Forum.last
        subject.add_permission "leader", Group
        subject.add_permission "warrior"
      end
      
      it { subject.has_any_permission?({ :name => "visitor", :resource => Forum.last }).should be_truthy }
      it { subject.has_any_permission?({ :name => "moderator", :resource => Forum.first }, { :name => "visitor", :resource => Forum.last }).should be_truthy }
      it { subject.has_any_permission?({ :name => "moderator", :resource => :any }, { :name => "visitor", :resource => Forum.last }).should be_truthy }
      it { subject.has_any_permission?({ :name => "moderator", :resource => :any }, { :name => "visitor", :resource => :any}).should be_truthy }
      it { subject.has_any_permission?({ :name => "moderator", :resource => Forum }, { :name => "visitor", :resource => :any }).should be_truthy }
      it { subject.has_any_permission?({ :name => "moderator", :resource => Forum.first }, { :name => "moderator", :resource => Forum.last }).should be_truthy }
      it { subject.has_any_permission?({ :name => "moderator", :resource => Forum.first }, { :name => "dummy", :resource => Forum.last }).should be_truthy }
      it { subject.has_any_permission?({ :name => "dummy", :resource => Forum.first }, { :name => "dumber", :resource => Forum.last }).should be_falsey }
      it { subject.has_any_permission?("warrior", { :name => "moderator", :resource => Forum.first }, { :name => "leader", :resource => Group }).should be(true) }
      it { subject.has_any_permission?("warrior", { :name => "moderator", :resource => :any }, { :name => "leader", :resource => Forum }).should be(true) }
      it { subject.has_any_permission?("warrior", { :name => "moderator", :resource => Forum.first }, { :name => "leader", :resource => :any }).should be(true) }
      it { subject.has_any_permission?("warrior", { :name => "moderator", :resource => :any }, { :name => "leader", :resource => :any }).should be(true) }
      it { subject.has_any_permission?("warrior", { :name => "moderator", :resource => Forum.last }, { :name => "leader", :resource => Forum }).should be(true) }
      it { subject.has_any_permission?("warrior", { :name => "moderator", :resource => Forum.last }, { :name => "leader", :resource => Group }).should be(true) }
      it { subject.has_any_permission?("warrior", { :name => "moderator", :resource => Forum.last }, { :name => "leader", :resource => Group.first }).should be(true) }
      it { subject.has_any_permission?({ :name => "warrior", :resource => Forum }, { :name => "moderator", :resource => Forum.last }, { :name => "leader", :resource => Forum }).should be(true) }
      it { subject.has_any_permission?({ :name => "warrior", :resource => Forum.first }, { :name => "moderator", :resource => Forum.last }, { :name => "leader", :resource => Forum }).should be(true) }
      it { subject.has_any_permission?("warrior", { :name => "moderator", :resource => Forum.last }, { :name => "leader", :resource => Forum.first }).should be(true) }
      it { subject.has_any_permission?("dummy", { :name => "dumber", :resource => Forum.last }, { :name => "dumberer", :resource => Forum }).should be(false) }
      it { subject.has_any_permission?({ :name => "leader", :resource => Group.last }, "dummy", { :name => "dumber", :resource => Forum.last }, { :name => "dumberer", :resource => Forum }).should be(true) }
    end
  end
end