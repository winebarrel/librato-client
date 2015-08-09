class Librato::Client::Error < StandardError
  attr_reader :cause

  def initialize(cause)
    super(cause.response)
    @cause = cause
  end
end
