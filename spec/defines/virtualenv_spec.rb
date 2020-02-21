require 'spec_helper'

describe 'python::virtualenv' do
  let(:title) { '/opt/v' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with python3' do
        three_versions(facts).each do |three_version|
          context "version #{three_version}" do
            if three_version.nil?
              puts "skipping python3 tests on #{facts[:os]}"
              next
            end
            let :pre_condition do
              "
              class {'python':
                version    => '#{three_version}',
                virtualenv => true,
              }
              "
            end

            case facts[:osfamily]
            when 'OpenBSD'
              it do
                is_expected.to contain_exec('python_virtualenv_/opt/v').with_command(
                  # /virtualenv-3\s+-p\spython-#{short_version}\s\/opt\/v/
                  %r{virtualenv-3\s+-p\spython\s\/opt\/v}
                )
              end

            when 'FreeBSD'
              case three_version
              when '34'
                it do
                  is_expected.to contain_exec('python_virtualenv_/opt/v').with_command(
                    %r{virtualenv-3.4\s+-p\spython\s\/opt\/v}
                  )
                end

              when '35'
                it do
                  is_expected.to contain_exec('python_virtualenv_/opt/v').with_command(
                    %r{virtualenv-3.5\s+-p\spython\s\/opt\/v}
                  )
                end

              end

            else
              it { is_expected.to contain_python__virtualenv('/opt/v') }
              it do
                is_expected.to contain_exec('python_virtualenv_/opt/v').with_command(
                  # /virtualenv-3\s+-p\spython-#{short_version}\s\/opt\/v/
                  %r{virtualenv\s+-p\spython\s\/opt\/v}
                )
              end
            end
          end
        end
      end
    end
  end
end
