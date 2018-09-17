require('rspec')
require('go_fish_game')
require('./mock/mock_socket_client')
require('go_fish_socket_server')
require('go_fish_socket_game_runner')

describe(GoFishSocketGameRunner) do
  attr_reader :clients, :server
  let(:game_setup) do
    client_struct = new_client_struct
    client_struct.client.provide_input('Joey')
    client_struct.client.provide_input('create')
    client_struct.client.provide_input('2')
    sleep(0.1)
    game = server.pending_games[0].game
    client2_struct = new_client_struct
    client2_struct.client.provide_input('Roy')
    client2_struct.client.provide_input('join')
    client2_struct.client.provide_input(server.pending_games[0].game_id)
    sleep(0.1)
    [game, client_struct, client2_struct]
  end

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
    server.start
  end

  after(:each) do
    server.stop
    clients.each(&:close)
  end

  describe('#start') do
    it('inform all players that game started') do
      game, client1_struct, client2_struct = game_setup
      game_runner = GoFishSocketGameRunner.new(game)
      game_runner.start
      expect(client1_struct.client.capture_output).to match(/Game started/)
      expect(client2_struct.client.capture_output).to match(/Game started/)
    end
  end

  describe('#inform_round_start') do
    it('inform current player it\'s their turn') do
      game, client1_struct, client2_struct = game_setup
      game_runner = GoFishSocketGameRunner.new(game)
      game_runner.inform_round_start
      expect(client1_struct.client.capture_output).to match(/It's your turn/)
      expect(client2_struct.client.capture_output).not_to match(/It's your turn/)
    end
  end

  describe('#inform_players_of_their_hand') do
    it('inform players of their hand') do
      game, client1_struct, client2_struct = game_setup
      game_runner = GoFishSocketGameRunner.new(game)
      game_runner.start
      game_runner.inform_players_of_their_hand
      expect(client1_struct.client.capture_output).to match(/Spades/).or match(/Diamonds/)
      expect(client2_struct.client.capture_output).to match(/Spades/).or match(/Diamonds/)
    end
  end

  describe('#request_cards_from_player') do
    it('request card from other player') do
      game, client1_struct = game_setup
      game_runner = GoFishSocketGameRunner.new(game)
      game_runner.start
      client1_struct.client.provide_input('ask Roy for 4s')
      expect(game_runner.send(:request_cards_from_player)).to match(/Joey/)
    end
  end
end
