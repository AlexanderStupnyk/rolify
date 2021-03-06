require 'rspec/expectations'

RSpec::Matchers.define :have_permission do |*args|
  match do |resource|
    resource.has_permission?(*args)
  end

  failure_message do |resource|
    "expected to have permission #{args.map(&:inspect).join(" ")}"
  end

  failure_message_when_negated do |resource|
    "expected not to have permission #{args.map(&:inspect).join(" ")}"
  end
end

RSpec::Matchers.define :be_the_same_permission do |*expected|
  match do |actual|
    if expected.size > 1 
      if expected[1].is_a? Class
        actual[:name] == expected[0] && actual[:resource_type] == expected[1].to_s
      else
        actual[:name] == expected[0] && 
        actual[:resource_type] == expected[1].class.name &&
        actual[:resource_id] == expected[1].id
      end
    else
      actual[:name] == expected[0]
    end
  end
end