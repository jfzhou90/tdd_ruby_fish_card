require('rspec')
require('socket')
require('./lib/client_setup')
require('./mock/mock_socket_client')
require('./mock/mock_server')

describe(ClientSetup) do
  attr_reader :clients, :mock_server

  def new_client_struct
    client_struct = Client.new(
      MockSocketClient.new(mock_server.port_number),
      mock_server.accept_new_client
    )
    clients.push(client_struct.client)
    client_struct
  end

  before(:each) do
    @clients = []
    @mock_server = GoFishMockServer.new
    mock_server.start
  end

  after(:each) do
    mock_server.stop
    clients.each(&:close)
  end

  describe('#capture_output') do
    it('captures the output from the client') do
      client_struct = new_client_struct
      client_struct.client.provide_input('Testing Setup')
      client_setup = ClientSetup.new(mock_server, client_struct.server_side_socket)
      message = client_setup.send(:capture_output)
      expect(message).to eq('Testing Setup')
    end
  end

  describe('#ask_for_name') do
    it('ask for name, expect client to get the question') do
      client_struct = new_client_struct
      client_setup = ClientSetup.new(mock_server, client_struct.server_side_socket)
      client_struct.client.provide_input('Bob')
      client_setup.send(:create_player)
      expect(client_struct.client.capture_output).to eq("What\'s your name?")
      expect(client_setup.send(:name)).to eq('Bob')
    end
  end

  describe('#ask_to_create_or_join') do
    it('ask the client what he/she wants to do. Create or join.') do
      client_struct = new_client_struct
      client_setup = ClientSetup.new(mock_server, client_struct.server_side_socket)
      client_struct.client.provide_input('create')
      client_setup.send(:ask_to_create_or_join)
      expect(client_struct.client.capture_output).to match(/start a game or join one?/)
    end
  end

  describe('#ask_how_many_players') do
    it('ask the client how many players for the game?') do
      client_struct = new_client_struct
      client_setup = ClientSetup.new(mock_server, client_struct.server_side_socket)
      client_struct.client.provide_input('7')
      client_setup.send(:ask_how_many_players)
      expect(client_struct.client.capture_output).to match(/How many players for the game?/)
    end
  end

  describe('#ask_which_game') do
    it('ask which game to join, repeat until valid') do
      client_struct = new_client_struct
      client_setup = ClientSetup.new(mock_server, client_struct.server_side_socket)
      client_struct.client.provide_input('test_game')
      client_setup.send(:ask_which_game)
      expect(client_struct.client.capture_output).to match(/Which game would you like to join?/)
    end
  end
end
