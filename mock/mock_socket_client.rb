class MockSocketClient
  attr_reader :socket

  def initialize(port)
    @socket = TCPSocket.new('localhost', port)
  end

  def close
    socket.close if socket
  end

  def capture_output
    sleep(0.1)
    socket.read_nonblock(1000).chomp # not gets which blocks
  rescue IO::WaitReadable
    ''
  end

  def provide_input(text)
    sleep(0.1)
    socket.puts(text)
    sleep(0.1)
  end
end
