class AlpineSecdbCloner
  attr_reader :destination_path

  def initialize(destination_path)
    @destination_path = destination_path
  end

  def update!
    ensure_clone!
    pull!
  end

private
  def ensure_clone!
    return if Dir.exist?(destination_path)
    Dir.chdir(File.dirname(destination_path)) do
      `git clone git://git.alpinelinux.org/alpine-secdb`
    end
  end

  def pull!
    Dir.chdir(destination_path) do
      `git pull`
    end
  end
end
