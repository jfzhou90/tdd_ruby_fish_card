require('card_deck')

describe(CardDeck) do
  let(:deck) { CardDeck.new }
  let(:deck2) { CardDeck.new }

  describe('#initialize') do
    it('starts the deck with 52 cards') do
      expect(deck.deck_size).to be(52)
    end
  end

  describe('#Deal') do
    it('removes a card from the deck') do
      card = deck.deal
      expect(deck.deck_size).to be(51)
      expect(card).to be_an_instance_of(PlayingCard)
    end
  end

  describe('#shuffle') do
    it('shuffles the deck into a random order, may fail 1/52 of the time.') do
      deck.shuffle
      card = deck.deal
      expect(card.to_s).to_not eq('A of Spades')
    end
  end
end
