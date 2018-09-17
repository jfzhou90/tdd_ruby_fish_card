require('socket')
require('./lib/go_fish_game')
require('./lib/client_setup')
require('./lib/go_fish_socket_game_runner')

Pending_Game_Struct = Struct.new(:game_id, :game, :player_count)

class GoFishSocketServer
  def port_number
    3336
  end

  def start
    @server = TCPServer.new(port_number)
  end

  def stop
    server.close if server
  end

  def pending_games
    @pending_games ||= []
  end

  def accept_new_client
    client = server.accept_nonblock
    send_message(client, 'Welcome.')
    setup_client(client)
  rescue IO::WaitReadable, Errno::EINTR
    # puts 'No client to accept'
  end

  def create_game(player, player_count)
    game_id = generate_game_id
    game = GoFishGame.new(player: player)
    pending_games.push(Pending_Game_Struct.new(game_id, game, player_count))
  end

  def join_game(player, game_id)
    pending_struct = pending_games.detect { |pending| pending.game_id == game_id }
    pending_struct.game.add_player(player)
    check_game_readiness(pending_struct)
  end

  def run_game(game)
    game_runner = GoFishSocketGameRunner.new(game)
    game_runner.start
    Thread.start do
      game_runner.play until game_runner.finished?
    end
  end

  private

  attr_reader :server

  def generate_game_id
    "Game-#{rand(111_111..999_999)}"
  end

  def games_to_humans
    @games_to_humans ||= {}
  end

  def send_message(client, text)
    sleep(0.1)
    client.puts(text)
  end

  def setup_client(client)
    client_setup = ClientSetup.new(self, client)
    Thread.start do
      client_setup.start
    end
    client
  end

  def check_game_readiness(game_struct)
    return unless game_struct.game.players_size == game_struct.player_count

    pending_games.reject! { |pending| pending.game_id == game_struct.game_id }
    game_struct.game
  end
end
