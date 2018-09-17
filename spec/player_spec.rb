require('rspec')
require('player')
require('playing_card')

describe(Player) do
  let(:player) { Player.new(name: 'Clark Kent') }
  let(:card1) { PlayingCard.new(rank: 'A', suit: 'Spades') }
  let(:card2) { PlayingCard.new(rank: 'A', suit: 'Clubs') }
  let(:card3) { PlayingCard.new(rank: 'A', suit: 'Hearts') }
  let(:card4) { PlayingCard.new(rank: 'A', suit: 'Diamonds') }
  let(:cards) { [card1, card2, card3, card4] }

  describe('#initialize') do
    it('expect name to be what was initialized') do
      expect(player.name).to eq('Clark Kent')
    end
  end

  describe('#add_card') do
    it('add card or cards to player\'s hand') do
      expect(player.cards_left).to eq(0)
      player.add_cards([card1])
      expect(player.cards_left).to eq(1)
      player.add_cards([card2, card3, card4])
      expect(player.cards_left).to eq(4)
    end

    it('add array of cards to player\' hand') do
      expect(player.cards_left).to eq(0)
      player.add_cards(cards)
      expect(player.cards_left).to eq(4)
    end
  end

  describe('#give_card') do
    it('removes the cards of the same rank from player') do
      player.add_cards(cards)
      player.add_cards([PlayingCard.new(rank: '2', suit: 'Diamonds')])
      expect(player.give('A').all? { |card| card.rank == 'A' }).to be(true)
      expect(player.cards_left).to eq(1)
    end
  end

  describe('#any_ranks?') do
    it('returns boolean whether player have the ranks') do
      player.add_cards(cards)
      expect(player.any_rank?('K')).to be(false)
      expect(player.any_rank?('A')).to be(true)
    end
  end

  # describe('#check_complete') do # moved to private method
  #   it('puts 4 of a kind into completed set collection') do
  #     player.add_cards(*cards)
  #     expect(player.check_complete).to eq(['A'])
  #     expect(player.completed_count).to eq(1)
  #   end
  # end
end
