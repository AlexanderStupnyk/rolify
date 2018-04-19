require "spec_helper"

describe Rolify do

  context 'cache' do
    let(:user) { User.first }
    before { user.grant(:zombie) }
    specify do
      expect(user).to have_permission(:zombie)
      user.remove_permission(:zombie)
      expect(user).to_not have_permission(:zombie)
    end
  end
end
