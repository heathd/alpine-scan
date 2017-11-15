require 'docker'
require 'package'
require 'version_number'
require 'alpine_secdb'

class Scanner
  attr_reader :secdb

  def initialize(secdb_path)
    @secdb = AlpineSecDB.new(secdb_path)
  end

  def list_packages(image_name)
    c = Docker::Image.get(image_name).run("apk -v info")
    c.wait(5)
    stdout = c.streaming_logs(stdout: true)
    c.remove
    stdout.split("\n").map do |string|
      Package.new($1, VersionNumber.new($2))
    end
  end

  def patched?(package)
    patches(package).any?
  end

  def patches(package)
    info = secdb.package_info('3.6', package.name)
    if info
      info.security_releases.select { |r| r.version > package.version }
    else
      []
    end
  end

  def scan(image_name)
    packages = list_packages(image_name)
    to_patch = packages
      .map {|p| [p, patches(p)] }
      .reject {|p, patches| patches.empty?}

    to_patch.each do |package, patches|
      puts "#{package.name} (currently #{package.version})"
      patches.each do |patch|
        puts "  #{patch.version} fixes #{patch.cves_fixed_in_this_release.join(', ')}"
      end
    end

    puts "Scanning complete: #{packages.size} packages of which #{to_patch.size} need updating"
    return to_patch.empty?
  end
end
