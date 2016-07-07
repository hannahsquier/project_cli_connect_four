require 'pry'
class Game

  def initialize
    welcome
    play
  end

  def play
    until win?
      @player1.ask_move
      @player2.ask_move
      [@player1, @player2].each_with_index do |player, index| 
        @board.add_piece(player.move, index)
      end
      @board.render
    end
    puts "Congratulations! Game over."
  end

  def welcome
    puts "Welcome to Connect Four?"
    @board = Board.new
    ask_mode
    set_players
  end

  def ask_mode
    puts "How many players? [one, two]"
    @mode = gets.chomp == 'one' ? :computer : :human
  end

  def set_players
    case @mode
    when :human
      puts "Enter Player 1's name."
      @player1 = Player.new(gets.chomp)
      puts "Enter Player 2's name."
      @player2 = Player.new(gets.chomp)
    when :computer
      puts "Enter Player 1's name."
      @player1 = Player.new(gets.chomp)
      #set computer
      @player2 = Player.new(:computer)
    end
  end

  def win?
    @board.any_winning_rows? ||
    @board.any_winning_cols? ||
    @board.any_winning_diagonals?
  end

end


# DIAGONAL GENERATOR FOR CHECKING BOARD STATE
class DirectionGenerator

  attr_reader :combinations

  DIRECTIONS = [
    :n,
    :s,
    :e,
    :w,
    :nw,
    :ne,
    :sw,
    :se
  ]

  class << self

    def generate_directions(row, col, limit)
      DIRECTIONS.map do |direction| 
        dispatch(direction, row, col)
      end.select do |row|
        row.flatten.none? do |v| 
          v > limit || v < 0
        end 
      end
    end

    def dispatch(direction,row,col)
      case direction
      when :nw
        generate_diagonal(row,col,:-,:-)
      when :ne
        generate_diagonal(row,col,:-,:+)
      when :sw
        generate_diagonal(row,col,:+,:-)
      when :se
        generate_diagonal(row,col,:+,:-)
      when :n
        generate_cardinal(row,col,:row,:-)
      when :s
        generate_cardinal(row,col,:row,:+)
      when :e
        generate_cardinal(row,col,:col,:+)
      when :w
        generate_cardinal(row,col,:col,:-)
      end
    end

    def generate_cardinal(row,col,changing, op)
      return_array = []
      if changing == :row
        if op == :+
          (row..(row+3)).to_a.each do |row_num|
            return_array << [row_num, col]
          end
        elsif op == :-
          ((row-3)..row).to_a.each do |row_num|
            return_array << [row_num, col]
          end
        end
      elsif changing == :col
        if op == :+
          (col..(col+3)).to_a.each do |col_num|
            return_array << [row, col_num]
          end

        elsif op == :-
          ((col-3)..col).to_a.each do |col_num|
            return_array << [row, col_num]
          end
        end
      end
      return_array
    end

    def generate_diagonal(row,col,op,op2)
      return_array = [[row,col]]
      (1..3).to_a.each do |term|
        return_array << [(row.send(op,term)),(col.send(op2,term))]
      end
      return_array
    end

  end
end

class Board

  def initialize
    @state = [
      ["o","o","o","o","o","o"]
      ["o","o","o","o","o","o"]
      ["o","o","o","o","o","o"],
      ["o","o","o","o","o","o"],
      ["o","o","o","o","o","o"],
      ["o","o","o","o","o","o"]
    ]
  end

  def render
    @state.each do |row|
      p row
    end
  end

  def get_col(col)
    return_array = []
    @state.each do |row|
      return_array.push(row[col])
    end
    return_array
  end

  # Handles the adding of pieces
  def add_piece(col, type)
    @state.reverse_each do |row|
      unless peg_present(col, row)
        insert_peg(col, row, type)
        break
      end
    end
  end

  # Inserts a type into a supplied row at col
  def insert_peg(col, row, type)
    row[col] = convert_type(type)
  end

  # Converts player's index to type
  def convert_type(type)
    type == 0 ? '=' : '+'
  end

  #Check if peg already present.
  def peg_present(col,row)
    row[col] == '+' || row[col] == '='
  end

  def winning_combination?(combination)
    combination.all? { |peg| peg == "+" } || combination.all? { |peg| peg == "=" }
  end

  #Winning conditionals
  def any_winning_rows?
    # binding.pry
    @state.each do |row|
      return true if winning_combination? row
    end
    false
  end

  def any_winning_cols?
    (0..@state.first.length).each do |i|
      return true if winning_combination? get_col(i)
    end
    false
  end

  def any_winning_diagonals?
    # Diagonal 1
    # i = 0; j = 0
    # i++ j++

    diagonal_1 = [@state[0][0],
                  @state[1][1],
                  @state[2][2],
                  @state[3][3]]
    diagonal_2 = [@state[0][3],
                  @state[1][2],
                  @state[2][1],
                  @state[3][0]]
    winning_combination?(diagonal_1) || winning_combination?(diagonal_2)
  end

  # diagonal_generator based on place
  # e.g. place == [0,0] => all four directions
  # valid diagonal? (i.e. range within board)
  # iterate through each row; iterate through each col
  # throw the places into diagonal_generator, generator spits out diagonals
  # check diagonals for valid diagonal

end

class Player
  attr_reader :move
  def initialize(name)
    case name
    when String
      @name = name
      @mode = :human
    when Symbol
      @mode = :computer
    end
  end

  def ask_move
    case @mode
    when :human
      puts "Which column would you like to place your peg in?"
      @move = gets.chomp.to_i - 1
    when :computer
      @move = rand(4)
    end
  end

end


# def test
#   Game.new
# end

# test