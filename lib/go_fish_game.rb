require('./lib/card_deck')
require('./lib/player')

class GoFishGame
  attr_reader :deck, :players, :started, :winner

  def initialize(player:, deck: CardDeck.new)
    @deck = deck
    @players = [player]
    @round = 0
    @started = false
    @winner = nil
  end

  def start
    return unless players_size > 1

    self.started = true
    distribute_cards_to_player
  end

  def add_player(player)
    players.push(player) unless started
  end

  def current_player
    players[round % players_size]
  end

  def players_size
    players.size
  end

  def play_round(request_player, rank)
    return "#{winner} is the winner." if any_winner?
    return 'try a DIFFERENT player.' if current_player.name == request_player

    other_player = players.detect { |player| player.name.casecmp(request_player).zero? }
    return 'No such player, try again.' unless other_player

    other_player.any_rank?(rank) ? transfer_cards(other_player, rank) : go_fish(rank)
  end

  private

  attr_accessor :round
  attr_writer :players, :started, :winner

  def transfer_cards(player, rank)
    current_player.add_cards(player.give(rank))
    "#{current_player.name} takes #{rank}s from #{player.name}."
  end

  def next_player
    self.round = round + 1
  end

  def distribute_cards_to_player
    deck.shuffle
    init_cards_count = players_size > 3 ? 5 : 7
    init_cards_count.times do
      players.each { |player| player.add_cards([deck.deal]) }
    end
  end

  def go_fish(rank)
    player = current_player
    card = deck.deal
    current_player.add_cards([card])
    return "#{current_player.name} fished the desired #{rank} from the pond." if card.rank == rank

    next_player
    "#{player.name} fished a card. Next player: #{current_player.name}"
  end

  def any_winner?
    if players.any?(&:empty?)
      self.winner = player_with_highest_score
    else
      false
    end
  end

  def player_with_highest_score
    players.max { |player| player.completed_set.count }.name
  end
end
