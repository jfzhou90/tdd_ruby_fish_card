require('socket')
require('./lib/go_fish_game')
require('./lib/client_setup')

class GoFishMockServer
  def port_number
    3333
  end

  def start
    @server = TCPServer.new(port_number)
  end

  def pending_games
    @pending_games = [ Pending_Game_Struct.new('test_game', 'game', 7) ]
  end

  def stop
    server.close if server
  end

  def accept_new_client
    sleep(0.1)
    server.accept_nonblock
  rescue IO::WaitReadable, Errno::EINTR
    # puts 'No client to accept'
  end

  private

  attr_reader :server

  def setup_client(client)
    client_setup = ClientSetup.new(server, client)
    client_setup.start
    client
  end
end
