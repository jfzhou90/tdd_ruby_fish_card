require('./lib/go_fish_server_side_socket')

class Player
  attr_reader :name, :completed_set, :client, :hand

  def initialize(name: 'Stranger', socket: nil)
    @name = name
    @hand = []
    @completed_set = []
    @client = GoFishServerSideSocket.new(socket) unless socket.nil?
  end

  def add_cards(array_of_cards)
    hand.concat(array_of_cards)
  end

  def cards_left
    hand.length
  end

  def give(rank)
    cards = hand.select { |card| card.rank == rank }
    hand.reject! { |card| card.rank == rank }
    cards
  end

  def completed_count
    completed_set.length
  end

  def any_rank?(rank)
    ranks.include?(rank)
  end

  def empty?
    cards_left.zero?
  end

  private

  attr_writer :hand

  def make_a_book(rank)
    hand.reject! { |card| card.rank == rank }
    completed_set.push(rank)
  end

  def count(rank)
    hand.count { |card| card.rank == rank }
  end

  def ranks
    hand.map(&:rank).uniq
  end

  def check_complete
    ranks.each { |rank| make_a_book(rank) if count(rank) == 4 }
  end
end
