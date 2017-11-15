class VersionNumber < Struct.new(:major, :minor, :patch, :patchlevel, :release)
  include Comparable

  def initialize(version_string)
    valid?(version_string) or raise("Can't parse '#{version_string}'")
    parse!(version_string)
  end

  def valid?(version_string)
    version_string =~ %r{^((?:[0-9]+\.)*[0-9]+(?:[a-zA-Z]*)(?:-r(?:[0-9]+)))?}
  end

  def parse!(version_string)
    parts = version_string.split('-r')
    self.release = parts.last && parts.last.to_i
    version_parts = parts.first.split('.')

    if version_parts[-1] =~ %r{^([0-9]+)(?:([a-zA-Z]+)|_([a-zA-Z0-9]+))$}
      version_parts[-1] = $1.to_i
      self.patchlevel = $2 || $3
    end

    (self.major, self.minor, self.patch) = version_parts.map(&:to_i)
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
