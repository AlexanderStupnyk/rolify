require 'spec_helper'

describe 'have_permission', focus: true do
  let(:object) { Object.new }

  it 'delegates to has_permission?' do
    object.should_receive(:has_permission?).with(:read, 'Resource') { true }
    object.should have_permission(:read, 'Resource')
  end

  it 'reports a nice failure message for should' do
    object.should_receive(:has_permission?) { false }
    expect{
      object.should have_permission(:read, 'Resource')
    }.to raise_error('expected to have permission :read "Resource"')
  end

  it 'reports a nice failure message for should_not' do
    object.should_receive(:has_permission?) { true }
    expect{
      object.should_not have_permission(:read, 'Resource')
    }.to raise_error('expected not to have permission :read "Resource"')
  end
end
