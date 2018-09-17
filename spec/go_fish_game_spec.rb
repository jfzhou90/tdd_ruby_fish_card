require('go_fish_game')
require('rspec')
require('player')
require('card_deck.rb')
require('playing_card')

Game_Struct = Struct.new(:game, :player1, :player2)

describe(GoFishGame) do
  let(:player) { Player.new(name: 'First') }
  let(:player2) { Player.new(name: 'Second') }
  let(:game) { GoFishGame.new(player: player) }
  let(:dupCards) do
    [
      PlayingCard.new(rank: '2', suit: 'Spades'),
      PlayingCard.new(rank: '2', suit: 'Heart'),
      PlayingCard.new(rank: '2', suit: 'Clubs')
    ]
  end
  let(:game_init) do
    player1 = Player.new(name: '1st')
    player2 = Player.new(name: '2nd')
    game = GoFishGame.new(player: player1, deck: TestDeck.new)
    game.add_player(player2)
    game.start
    Game_Struct.new(game, player1, player2)
  end

  describe('#initialize') do
    it('have a deck of cards') do
      expect(game.deck.deck_size).to be(52)
    end
  end

  describe('#start') do
    it('distribute corrent number of cards for 2 players') do
      game.send(:distribute_cards_to_player)
      expect(game.players.map(&:cards_left).all?(7)).to be(true)
    end
  end

  describe('#players_size') do
    it('expect the correct number of players') do
      expect(game.players_size).to be(1)
    end
  end

  describe('#add_player') do
    it('adds a new player, and change the size of player') do
      game.add_player(Player.new)
      expect(game.players_size).to be(2)
    end

    it('can\'t add player after game started') do
      game.add_player(Player.new) # needed 2 players to start the game
      game.start
      game.add_player(Player.new)
      expect(game.players_size).to be(2)
    end
  end

  describe('#current_player') do
    it('returns the player of the current round') do
      expect(game.current_player.name).to eq('First')
    end
  end

  describe('#transfer_cards') do
    it('transfer all the 2s from player2 to player1 ') do
      game_struct = game_init
      expect(game_struct.player2.any_rank?('2')).to be(true)
      game_struct.game.send(:transfer_cards, game_struct.player2, '2')
      expect(game_struct.player2.any_rank?('2')).to be(false)
      expect(game_struct.player1.send(:hand).select { |card| card.rank == '2' }.count).to be(2)
    end
  end

  describe('#play_round') do
    it('make a request and transfer cards to the winning player') do
      game_struct = game_init
      result = game_struct.game.play_round('2nd', '2')
      expect(result).to eq('1st takes 2s from 2nd.')
    end

    it('failed to fish from player, now fishing from pond unsuccessfully.') do
      game_struct = game_init
      result = game_struct.game.play_round('2nd', '6')
      expect(result).to eq('1st fished a card. Next player: 2nd')
    end

    it('prevents player from entering their own name') do
      game_struct = game_init
      result = game_struct.game.play_round('1st', '2')
      expect(result).to eq('try a DIFFERENT player.')
    end
  end

  describe('#player_with_highest_score') do
    it('finds the player with highest score') do
      game_struct = game_init
      game_struct.player2.add_cards(dupCards)
      game_struct.player2.send(:check_complete)
      expect(game_struct.game.send(:player_with_highest_score)).to eq('2nd')
    end
  end

  describe('#any winner?') do
    it('sets the winner to the person with highest score') do
      game_struct = game_init
      game_struct.player2.add_cards(dupCards)
      game_struct.player2.send(:check_complete)
      game_struct.player1.send(:hand=, [])
      game_struct.game.send(:any_winner?)
      expect(game_struct.game.winner).to eq('2nd')
      expect(game_struct.game.play_round('random', 'test')).to eq('2nd is the winner.')
    end
  end
end
