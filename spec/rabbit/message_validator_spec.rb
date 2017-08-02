require_relative '../spec_helper'

class MyClass
  include Mopsy::Rabbit::MessageValidator

  attr_reader :missing

  def do_things
    @missing = []
    h        = { foo: "bar", baz: "bat" }

    must_set h, :foo
    must_set h, :fish
  end
end

RSpec.describe Mopsy::Rabbit::MessageValidator do
  describe '#must_set' do
    it 'should set instance variables on the including class' do
      m = MyClass.new
      m.do_things
      expect(m.foo).to eq('bar')
      expect(m.missing).to include(:fish)
    end
  end
end
