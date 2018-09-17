require('rspec')
require('socket')
require('./lib/go_fish_socket_server')
require('./mock/mock_socket_client')
require('./lib/player')

Client = Struct.new(:client, :server_side_socket)

describe(GoFishSocketServer) do
  attr_reader :clients, :server

  def new_client_struct
    client_struct = Client.new(
      MockSocketClient.new(server.port_number),
      server.accept_new_client
    )
    clients.push(client_struct.client)
    client_struct
  end

  before(:each) do
    @clients = []
    @server = GoFishSocketServer.new
  end

  after(:each) do
    server.stop
    clients.each(&:close)
  end

  describe('socket') do
    it 'is not listening on a port before it is started' do
      expect { MockSocketClient.new(server.port_number) }.to raise_error(Errno::ECONNREFUSED)
    end
  end

  describe('#accept_new_client') do
    it('accepts a client, client should get a message from server') do
      server.start
      client = new_client_struct.client
      expect(client.capture_output).to match(/Welcome/)
    end
  end

  describe('#create_game') do
    it('pending game consist of the new game') do
      server.create_game(Player.new, 7)
      expect(server.pending_games.length).to be(1)
    end
  end

  describe('#join_game') do
    it('add a player to the pending game.') do
      server.create_game(Player.new, 7)
      game_id = server.pending_games[0].game_id
      server.join_game(Player.new, game_id)
      expect(server.pending_games[0].game.players_size).to be(2)
    end
  end

  describe('#check_game_readiness') do
    it('removes game from pending when it\'s ready.') do
      server.create_game(Player.new, 2)
      server.pending_games[0].game.add_player(Player.new)
      server.send(:check_game_readiness, server.pending_games[0])
      expect(server.pending_games.length).to be(0)
    end
  end
end
