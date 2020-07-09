require 'spec_helper'
describe 'ha' do
  context 'with default values for all parameters' do
    it { should contain_class('ha') }
  end
end
