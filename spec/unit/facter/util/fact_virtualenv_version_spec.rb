require 'spec_helper'

describe Facter::Util::Fact do
  before do
    Facter.clear
  end

  let(:exec) {}

  let(:virtualenv_version_output) do
    <<-EOS
12.0.7
EOS
  end

  describe 'virtualenv_version' do
    context 'returns virtualenv version when virtualenv present' do
      it do
        expect(Facter::Util::Resolution).to receive(:which).with('virtualenv').and_return(true)
        expect(Facter::Util::Resolution).to receive(:exec).with('virtualenv --version 2>&1').and_return(virtualenv_version_output)
        Facter.value(:virtualenv_version).should == '12.0.7'
      end
    end

    context 'returns nil when virtualenv not present' do
      it do
        expect(Facter::Util::Resolution).to receive(:which).with('virtualenv').and_return(false)
        Facter.value(:virtualenv_version).should.nil?
      end
    end
  end
end
