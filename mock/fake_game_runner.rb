puts "Welcome. What's your name? :"
name = gets.chomp

print 'Would you like to create a game or join a game? :'
input = gets.chomp

case input
when 'create'
  print 'How many player?: '
  input = gets.chomp.to_i
  puts 'Your game ID is GF123456.'
  puts "Waiting for other #{input - 1} players."

when 'join'
  print "What's the game ID? :"
  input = gets.chomp
  puts "Joined game #{input}."
end

puts 'Game started!'
puts "#{name}, Bob, Joe"
puts "#{name}, it's your turn."
print 'Which player do you want to request from? :'

player = gets.chomp
print 'Which rank? :'
rank = gets.chomp

puts "#{player} gave you 2 #{rank}."
puts 'Here are your cards 2 of Hearts, 3 of Diamonds, 4 of Spades.'
puts "Here's the completed books: 'A'."

puts "#{name}, gets to go again."
print 'Which player do you want to request from? :'

player = gets.chomp
print 'Which rank? :'
rank = gets.chomp
puts "#{player} has no #{rank}. Fished '5 of Spades' from the deck."
puts 'Here are your cards 2 of Hearts, 3 of Diamonds, 4 of spades, 5 of Spades.'
puts "Here's the completed books: 'A'."
puts "End of #{player}'s turn'"
