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
      if string =~ %r{^(.*?)-((?:[0-9]+\.)*[0-9]+-r(?:[0-9]+))}
        Package.new($1, VersionNumber.new($2))
      else
        raise "Can't parse #{string}"
      end
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

    if to_patch.any?
      to_patch.each do |package, patches|
        puts "#{package.name} (currently #{package.version})"
        patches.each do |patch|
          puts "  #{patch.version} fixes #{patch.cves_fixed_in_this_release.join(', ')}"
        end
      end
    else
      puts "No pending security patches"
    end
  end
end
