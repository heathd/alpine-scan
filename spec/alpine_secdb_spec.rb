require 'alpine_secdb'

RSpec.describe AlpineSecDB do
  let(:db_path) { File.dirname(__FILE__) + '/fixtures/alpine-secdb' }
  subject(:secdb) { AlpineSecDB.new(db_path) }

  describe '#package_info' do
    it 'lists the vulnerabilities of the given package in the given distro version' do
      info = secdb.package_info('3.6', 'apache2')

      expect(info.package_name).to eq('apache2')
      expect(info.security_releases.size).to eq(3)
      expect(info.security_releases.first.version).to eq(VersionNumber.new('2.4.27-r1'))
      expect(info.security_releases.first.cves_fixed_in_this_release).to eq(['CVE-2017-9798'])
    end
  end
end
