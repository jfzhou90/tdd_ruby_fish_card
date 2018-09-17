require('./lib/player')

class ClientSetup
  def initialize(server, client)
    @client = client
    @server = server
  end

  def start
    create_player until name
    decision = ask_to_create_or_join
    client_decides(decision)
    server.create_game(player, player_count) if player_count
    server.join_game(player, game_to_join) if game_to_join
  end

  private

  attr_reader :client, :server
  attr_accessor :name, :player_count, :game_to_join, :player

  def capture_output
    sleep(0.1)
    client.read_nonblock(1000).chomp
  rescue StandardError
    retry
  end

  def create_player
    client.puts("What's your name?")
    @name = capture_output
    @player = Player.new(name: name, socket: client)
  end

  def ask_to_create_or_join
    client.puts("#{name}, would you like to start a game or join one?")
    capture_output
  end

  def client_decides(decision)
    if /start/i =~ decision || /create/i =~ decision
      ask_how_many_players
    elsif /join/i =~ decision
      ask_which_game
    else
      ask_to_create_or_join
    end
  end

  def ask_how_many_players
    @player_count = 0
    until player_count >= 2
      client.puts('How many players for the game? Must be 2 or more.')
      self.player_count = capture_output.to_i
    end
  end

  def ask_which_game
    @game_to_join = nil
    games_list = server.pending_games.map(&:game_id).join(' ,')
    client.puts(games_list)
    until server.pending_games.detect { |game| game.game_id == game_to_join }
      client.puts('Which game would you like to join?')
      self.game_to_join = capture_output
    end
  end
end
