require 'yaml'
require 'version_number'
require 'pathname'

class AlpineSecDB
  attr_reader :db_path

  def initialize(db_path)
    @db_path = Pathname.new(db_path)
  end

  def package_info(alpine_release, package_name)
    packages(alpine_release).package_info(package_name)
  end

  def packages(alpine_release)
    PackageSet.new(
      load(alpine_release, 'community'),
      load(alpine_release, 'main')
    )
  end

  def load(release, file)
    YAML.load_file(db_path + "v#{release}" + "#{file}.yaml")
  end
end

class PackageSet
  attr_reader :packages

  def initialize(community_packages, main_packages)
    parse_set!(main_packages)
    parse_set!(community_packages)
  end

  def package_info(package_name)
    packages.find { |p| p.package_name == package_name }
  end

  def parse_set!(set)
    @packages ||= []
    meta = set.select { |k, _| %(distroversion reponame archs urlprefix apkurl).include?(k) }
    @packages += set['packages'].map do |package|
      PackageInfo.new(package['pkg'], meta)
    end
  end
end

class PackageInfo
  attr_reader :package_info, :meta

  def initialize(package_info, meta)
    @package_info = package_info
    @meta = meta
  end

  def package_name
    package_info['name']
  end

  def security_releases
    package_info['secfixes'].map do |release_string, cves|
      SecurityRelease.new(release_string, cves)
    end
  end
end

class SecurityRelease
  attr_reader :version, :cves_fixed_in_this_release

  def initialize(release_string, cves_fixed_in_this_release)
    @version = VersionNumber.new(release_string)
    @cves_fixed_in_this_release = cves_fixed_in_this_release
  end
end
