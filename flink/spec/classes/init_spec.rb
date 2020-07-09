require 'spec_helper'
describe 'flink' do
  context 'with default values for all parameters' do
    it { should contain_class('flink') }
  end
end
