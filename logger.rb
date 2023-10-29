class Logger
  def initialize(path)
    @log = File.open(path, 'a')
  end

  def info(message)
    @log.puts(message)
  end
end
