require 'spec_helper'

describe 'python::pyvenv', type: :define do
  let(:title) { '/opt/env' }

  it do
    is_expected.to contain_file('/opt/env')
    is_expected.to contain_exec('python_virtualenv_/opt/env').with_command('pyvenv --clear  /opt/env')
  end

  describe 'when ensure' do
    context 'is absent' do
      let(:params) do
        {
          ensure: 'absent'
        }
      end

      it do
        is_expected.to contain_file('/opt/env').with_ensure('absent').with_purge(true)
      end
    end
  end
end
