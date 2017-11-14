require 'scanner'
require 'package'

RSpec.describe Scanner do
  let(:db_path) { File.dirname(__FILE__) + "/fixtures/alpine-secdb" }
  subject(:scanner) { Scanner.new(db_path) }

  describe '#list_packages' do
    it "lists the versions of packages in the specified docker image" do
      packages = scanner.list_packages("govukpay/publicapi:latest-master")

      expected_package = Package.new("alpine-baselayout", VersionNumber.new("3.0.4-r0"))
      expect(packages.first).to eq(expected_package)
      expect(packages.size).to eq(55)
    end
  end

  describe '#patched?' do
    it 'given a package, reports whether it has a newer patch or not' do
      package = Package.new("apache2", VersionNumber.new('2.4.26-r1'))
      expect(scanner.patched?(package)).to be_truthy

      package = Package.new("apache2", VersionNumber.new('2.4.27-r1'))
      expect(scanner.patched?(package)).to be_falsy
    end
  end

  describe '#patches' do
    it 'given a package, lists the patches' do
      package = Package.new("apache2", VersionNumber.new('2.4.27-r0'))
      expect(scanner.patches(package).size).to eq(1)
      expect(scanner.patches(package).first.version).to eq(VersionNumber.new('2.4.27-r1'))
      expect(scanner.patches(package).first.cves_fixed_in_this_release).to eq(['CVE-2017-9798'])
    end
  end
end
