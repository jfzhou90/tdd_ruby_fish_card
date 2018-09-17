class GoFishSocketGameRunner
  def initialize(game)
    @game = game
  end

  def start
    inform_all_clients('Game started.')
    game.start
  end

  def play
    inform_players_of_their_hand
    inform_round_start
    request_cards_from_player
  end

  def finished?
    game.winner
  end

  def inform_round_start
    inform_current_client("It's your turn. #{game.current_player.name}")
    inform_current_client('What would you like to do? Ex: Ask Roy for 4s')
  end

  def inform_all_clients(text)
    all_clients.each do |client|
      client.provide_input(text)
    end
  end

  def inform_current_client(text)
    current_client.provide_input(text)
  end

  def listen_to_current_client
    current_client.capture_output
  rescue IO::WaitReadable
    retry
  end

  def inform_players_of_their_hand
    game.players.map do |player|
      player.client.provide_input(player.hand.join(', '))
    end
  end

  private

  attr_reader :game

  def request_cards_from_player
    request = listen_to_current_client
    result = request.match(/(?<name>\S+) for (?<rank>\D+|\d+)s/)
    return request_card_from_player unless result[:name] && result[:rank]

    game.play_round(result[:name], result[:rank])
  end

  def current_client
    game.current_player.client
  end

  def other_clients
    all_clients.reject { |client| client == current_client }
  end

  def all_clients
    game.players.map(&:client)
  end
end
