module Logging
  def log(*args)
    puts(*args) if ENV["LOG"] || ENV["DEBUG"]
  end

  def debug(*args)
    puts(*args) if ENV["DEBUG"]
  end
end
