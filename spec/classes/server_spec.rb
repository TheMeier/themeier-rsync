require 'spec_helper'
describe 'rsync::server', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      describe 'when using default params' do
        it {
          is_expected.to contain_class('xinetd')
          is_expected.to contain_xinetd__service('rsync').with('bind' => '0.0.0.0')
          is_expected.not_to contain_service('rsync')
          is_expected.to contain_concat__fragment('rsyncd_conf_header').with(order: '00_header')
          is_expected.to contain_concat__fragment('rsyncd_conf_header').with_content(%r{^use chroot\s*=\s*true$})
          is_expected.to contain_concat__fragment('rsyncd_conf_header').with_content(%r{^address\s*=\s*0.0.0.0$})
          is_expected.to contain_concat__fragment('rsyncd_conf_header').with_content(%r{^syslog facility\s*=\s*local3$})
        }
      end

      describe 'when disabling xinetd' do
        let :params do
          { use_xinetd: false }
        end

        it {
          is_expected.not_to contain_class('xinetd')
          is_expected.not_to contain_xinetd__service('rsync')
        }
        servicename = case facts[:os]['family']
                      when 'RedHat', 'Suse', 'FreeBSD'
                        'rsyncd'
                      else
                        'rsync'
                      end
        it { is_expected.to contain_service(servicename) }
      end

      describe 'when overriding use_chroot' do
        let :params do
          { use_chroot: false }
        end

        it {
          is_expected.to contain_concat__fragment('rsyncd_conf_header').with_content(%r{^use chroot\s*=\s*false$})
        }
      end

      describe 'when overriding address' do
        let :params do
          { address: '10.0.0.42' }
        end

        it {
          is_expected.to contain_concat__fragment('rsyncd_conf_header').with_content(%r{^address\s*=\s*10.0.0.42$})
        }
      end

      describe 'when overriding port' do
        let :params do
          { port: '2001' }
        end

        it {
          is_expected.to contain_concat__fragment('rsyncd_conf_header').with_content(%r{^port\s*=\s*2001$})
        }
      end

      describe 'when overriding uid' do
        let :params do
          { uid: 'testuser' }
        end

        it {
          is_expected.to contain_concat__fragment('rsyncd_conf_header').with_content(%r{^uid\s*=\s*testuser$})
        }
      end

      describe 'when overriding gid' do
        let :params do
          { gid: 'testgroup' }
        end

        it {
          is_expected.to contain_concat__fragment('rsyncd_conf_header').with_content(%r{^gid\s*=\s*testgroup$})
        }
      end
    end
  end
end
