class GoFishServerSideSocket
  attr_reader :client

  def initialize(client)
    @client = client
  end

  def provide_input(text)
    sleep(0.1)
    client.puts(text)
  end

  def capture_output
    sleep(0.1)
    client.read_nonblock(10_000)
  rescue IO::WaitReadable
    retry
  end
end
