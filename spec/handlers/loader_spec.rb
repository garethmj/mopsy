require_relative '../spec_helper'

require 'mopsy/handlers/loader'

RSpec.describe Mopsy::Handlers::Loader do
  describe '#find_handlers' do

    before do
      class Foo; end
      class Bar; end
      class Baz
        class Cheese; end
        class Parrot; end
        class Knight
          class Herring; end
        end
      end
    end

    context 'given a single class name' do
      describe 'without namespace' do
        it 'returns the worker class name' do
          expect(Mopsy::Handlers::Loader.find_handlers('Foo')).to eq([[Foo],[]])
        end
      end

      describe 'with namespace' do
        it 'returns the worker class name' do
          expect(Mopsy::Handlers::Loader.find_handlers('Baz::Cheese')).to eq([[Baz::Cheese],[]])
          expect(Mopsy::Handlers::Loader.find_handlers('Baz::Knight::Herring')).to eq([[Baz::Knight::Herring],[]])
        end
      end
    end

    context 'given a list of class names' do
      describe 'without namespaces' do
        it 'returns all worker class names' do
          expect(Mopsy::Handlers::Loader.find_handlers('Foo,Bar')).to eq([[Foo,Bar],[]])
        end
      end

      describe 'with namespaces' do
        it 'returns all worker class names' do
          workers = Mopsy::Handlers::Loader.find_handlers('Baz::Cheese,Baz::Parrot')
          expect(workers).to eq([[Baz::Cheese,Baz::Parrot],[]])
        end
      end
    end

    context 'given a non-existent class name' do
      describe 'without namespaces' do
        it 'returns an array of missing handler class names' do
          expect(Mopsy::Handlers::Loader.find_handlers('Ham,Foo')).to eq([[Foo],['Ham']])
        end
      end
    end
  end
end
