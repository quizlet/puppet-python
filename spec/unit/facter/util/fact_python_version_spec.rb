require 'spec_helper'

describe Facter::Util::Fact do
  before do
    Facter.clear
  end

  let(:exec) {}

  let(:python2_version_output) do
    <<-EOS
Python 2.7.9
EOS
  end
  let(:python3_version_output) do
    <<-EOS
Python 3.3.0
EOS
  end

  describe 'python_version' do
    context 'returns Python version when `python` present' do
      it do
        expect(Facter::Util::Resolution).to receive(:which).with('python').and_return(true)
        expect(Facter::Util::Resolution).to receive(:exec).with('python -V 2>&1').and_return(python2_version_output)
        Facter.value(:python_version).should == '2.7.9'
      end
    end

    context 'returns nil when `python` not present' do
      it do
        expect(Facter::Util::Resolution).to receive(:which).with('python').and_return(false)
        Facter.value(:python_version).should.nil?
      end
    end
  end

  describe 'python2_version' do
    context 'returns Python 2 version when `python` is present and Python 2' do
      it do
        expect(Facter::Util::Resolution).to receive(:which).with('python').and_return(true)
        expect(Facter::Util::Resolution).to receive(:exec).with('python -V 2>&1').and_return(python2_version_output)
        Facter.value(:python2_version).should == '2.7.9'
      end
    end

    context 'returns Python 2 version when `python` is Python 3 and `python2` is present' do
      it do
        expect(Facter::Util::Resolution).to receive(:which).with('python').and_return(true)
        expect(Facter::Util::Resolution).to receive(:exec).with('python -V 2>&1').and_return(python3_version_output)
        expect(Facter::Util::Resolution).to receive(:which).with('python2').and_return(true)
        expect(Facter::Util::Resolution).to receive(:exec).with('python2 -V 2>&1').and_return(python2_version_output)
        Facter.value(:python2_version).should == '2.7.9'
      end
    end

    context 'returns nil when `python` is Python 3 and `python2` is absent' do
      it do
        expect(Facter::Util::Resolution).to receive(:which).with('python').and_return(true)
        expect(Facter::Util::Resolution).to receive(:exec).with('python -V 2>&1').and_return(python3_version_output)
        expect(Facter::Util::Resolution).to receive(:which).with('python2').and_return(false)
        Facter.value(:python2_version).should.nil?
      end
    end

    context 'returns nil when `python2` and `python` are absent' do
      it do
        expect(Facter::Util::Resolution).to receive(:which).with('python').and_return(false)
        expect(Facter::Util::Resolution).to receive(:which).with('python2').and_return(false)
        Facter.value(:python2_version).should.nil?
      end
    end
  end

  describe 'python3_version' do
    context 'returns Python 3 version when `python3` present' do
      it do
        expect(Facter::Util::Resolution).to receive(:which).with('python3').and_return(true)
        expect(Facter::Util::Resolution).to receive(:exec).with('python3 -V 2>&1').and_return(python3_version_output)
        Facter.value(:python3_version).should == '3.3.0'
      end
    end

    context 'returns nil when `python3` not present' do
      it do
        expect(Facter::Util::Resolution).to receive(:which).with('python3').and_return(false)
        Facter.value(:python3_version).should.nil?
      end
    end
  end
end
