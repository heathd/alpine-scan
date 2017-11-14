class VersionNumber < Struct.new(:major, :minor, :patch, :patchlevel, :release)
  include Comparable

  def initialize(version_string)
    parse!(version_string)
  end

  def parse!(version_string)
    parts = version_string.split('-r')
    self.release = parts.last && parts.last.to_i
    (major, minor, patch_parts) = parts.first.split('.')
    self.major = major && major.to_i
    self.minor = minor && minor.to_i
    if patch_parts =~ %r{^([0-9]+)([a-zA-Z]+)$}
      self.patch = $1.to_i
      self.patchlevel = $2
    else
      self.patch = patch_parts && patch_parts.to_i
    end
  end

  def <=>(other_version)
    if version_vector.compact.size != other_version.version_vector.compact.size
      raise "Can't compare version numbers of different lengths"
    end
    version_vector <=> other_version.version_vector
  end

  def version_vector
    [major, minor, patch, patchlevel, release]
  end

  def to_s
    [
      version_vector[0..2].compact.join('.'),
      release
    ].compact.join('-r')
  end
end
