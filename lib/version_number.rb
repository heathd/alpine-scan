class VersionNumber < Struct.new(:major, :minor, :patch, :release)
  include Comparable

  def initialize(version_string)
    parse!(version_string)
  end

  def parse!(version_string)
    parts = version_string.split('-r')
    self.release = parts.last && parts.last.to_i
    (self.major, self.minor, self.patch) = parts.first.split('.').map(&:to_i)
  end

  def <=>(other_version)
    if version_vector.compact.size != other_version.version_vector.compact.size
      raise "Can't compare version numbers of different lengths"
    end
    version_vector <=> other_version.version_vector
  end

  def version_vector
    [major, minor, patch, release]
  end

  def to_s
    [
      version_vector[0..2].compact.join('.'),
      release
    ].compact.join('-r')
  end
end
