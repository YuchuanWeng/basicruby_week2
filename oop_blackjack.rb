#OPP in Ruby
#1. classes and objects
require 'rubygems'
require 'pry'

class Card
  #suit, value
  attr_accessor :suit
  attr_accessor :face_value
  def initialize(s, fv)
    @suit = s #instance variable
    @face_value = fv
  end

  def find_suit
    ret_val = case suit
      when 'H' then 'Hearts'
      when 'D' then 'Diamonds'
      when 'S' then 'Spades'
      when 'C' then 'Clubs'
      end
    ret_val
  end

   def printout
      "This is your card #{find_suit}, #{face_value}"
   end
   def to_s
    printout
   end
   #what is the purpose to seperate this two?
end

class Deck
   #combination
  attr_accessor :cards

  def initialize
    @cards = []
    ['H', 'D', 'S', 'C'].each do |suit|
      ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'].each do |face_value|
      @cards << Card.new(suit, face_value)
        end
    end
    scramble!
  end

  #shuffle the array
  def scramble!
    cards.shuffle!
  end

  def deal_one
    cards.pop
  end
end

module Hand
  def show_hand
    puts"#{name}, your hand:"
    cards.each do |card|
      puts "=> #{card}"
    end
    puts "=> Total: #{total}"
  end

  def total
     face_values = cards.map{|card| card.face_value}

     total = 0
     face_values.each do |val|
      if val == "A"
        total += 11
      else total += (val.to_i == 0 ? 10 : val.to_i)
      end
     end

     #for ACES
     face_values.select{|val| val == "A"}.count.times do
       break if total <= 21
       total -= 10
     end

     total
  end

  def add_card(new_card)
    cards << new_card
  end

  def is_busted?
    total > Blackjack::BLACKJACK_AMOUNT
  end
end

class Player
  include Hand
  attr_accessor :name, :cards

   def initialize(n)
    @name = n
    @cards = []
   end

  #simply for the consistency
   def show_flop
    show_hand
   end
end

class Dealer
  include Hand

  attr_accessor :name, :cards

  def initialize
    @name = "Dealer"
    @cards = []
  end

  def show_flop
    puts"Dealer's hand:"
    puts"=> First card is hidden"
    puts"=>Second card is #{cards[1]}" #show the second element,without the total
  end

end

class Blackjack
  attr_accessor :deck, :player, :dealer

  #This allowed you to change later easily
  BLACKJACK_AMOUNT = 21
  DEALER_HIT_MIN = 17

  def initialize
    @deck = Deck.new  #by creating the variable deck. it will create a new deck and can call method on it
    @player = Player.new('Player1')
    @dealer = Dealer.new
  end

  def set_player_name
    puts "What's your name?"
    player.name = gets.chomp #getter and setter
  end

  def deal_cards
    player.add_card(deck.deal_one)
    dealer.add_card(deck.deal_one)
    player.add_card(deck.deal_one)
    dealer.add_card(deck.deal_one)
  end

  def show_flop
    player.show_flop
    dealer.show_flop
  end

  def blackjack_or_bust?(player_or_dealer) # whether its player or dealer responde to the same method call.
    if player_or_dealer.total == BLACKJACK_AMOUNT
      if player_or_dealer.is_a?(Dealer)
        puts "Sorry. dealer hit blackjack. #{player.name} losses"
      else
        puts "Congrautions. You hit blackjack. You win!"
      end
      play_again?
    elsif player_or_dealer.is_busted?
      if player_or_dealer.is_a?(Dealer)
        puts "Sorry. dealer busted. #{player.name} win!"
      else
        puts "Sorry #{player.name} busted. Dealer win!"
      end
      play_again?
    end
  end

  def player_turn
    puts "#{player.name}'s turn"

    blackjack_or_bust?(player)

    while !player.is_busted?
      puts "What would you like to do? 1) hit 2) stay"
      response = gets.chomp

      if !['1','2'].include?(response)
        puts "Error: plesae enter 1 or 2"
      next
      end

      if response == '2'
        puts "#{player.name} choose to stay"
        break
      end

      #hit
      new_card = deck.deal_one
      puts "Dealing card to #{player.name}: #{new_card}"
      player.add_card(new_card)
      puts "#{player.name}'s total is now #{player.total}"

      blackjack_or_bust?(player)
    end
    puts "#{player.name} stays."
  end

  def dealer_turn
    puts "Dealer's turn."

    blackjack_or_bust?(dealer)
    while dealer.total < DEALER_HIT_MIN
      new_card = deck.deal_one
      puts "Dealing card to dealer: #{new_card}"
      dealer.add_card(new_card)
      puts "Dealer total is now: #{dealer.total}"

      blackjack_or_bust?(dealer)
    end
    puts "Dealer stays at #{dealer.total}."
  end

  def who_won?
    if player.total > dealer.total
      puts "Congratulation, #{player.name} wins!"
    elsif player.total < dealer.total
      puts "Sorry #{player.name} loses"
    else
      puts "it's a tie."
    end
    play_again?
  end

  def play_again?
    puts ""
    puts "Would you like to play again? 1) Yes 2)No, exit"

    if gets.chomp == '1'
      puts "Starting new game..."
      puts ""
      deck = Deck.new #initial the game again
      player.cards = [] #clear the card for a new game
      dealer.cards = []
      start
    else
      puts ""
      exit
    end
  end

  def start
    #Build the sequence of game, and we can start to build these methods
    set_player_name
    deal_cards
    show_flop
    player_turn
    dealer_turn
    who_won?
  end
end

game = Blackjack.new
game.start


#is a relationship
#has a relationship => Composition
